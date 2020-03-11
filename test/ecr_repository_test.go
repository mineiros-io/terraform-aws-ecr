package test

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"

	"context"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/client"

	"github.com/gruntwork-io/terratest/modules/docker"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/gruntwork-io/terratest/modules/terraform"

	goAws "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecr"
)

// Test that we can:
// 1. Build the docker image
// 2. Deploy the ECR repository
// 3. Authenticate with docker cli
// 4. Push the docker image to the ECR repository
func TestECRRepository(t *testing.T) {
	t.Parallel()

	workingDir := "../examples/ecr"
	repoName := strings.ToLower(fmt.Sprintf("ecr-repository-%s", random.UniqueId()))
	test_structure.SaveString(t, workingDir, "repoName", repoName)

	// At the end of the test, destroy all created Terraform resources
	defer test_structure.RunTestStage(t, "cleanup_terraform", func() {
		undeployTerraform(t, workingDir)
	})

	// Deploy the example with Terraform
	test_structure.RunTestStage(t, "deploy_terraform", func() {
		awsRegion := aws.GetRandomStableRegion(t, []string{"eu-west-1"}, nil)
		test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)
		deployUsingTerraform(t, repoName, awsRegion, workingDir)
	})

	// Authenticate with ECR and push the image
	test_structure.RunTestStage(t, "docker_build_and_push", func() {
		awsRegion := test_structure.LoadString(t, workingDir, "awsRegion")

		// Load AWS session
		session, err := aws.NewAuthenticatedSession(awsRegion)
		if err != nil {
			t.Fatalf("An error occurred while initializing the session %s", err)
		}

		authorizationDetails, err := getAuthorizationDetails(session, awsRegion)
		if err != nil {
			t.Fatalf("An error occurred while trying to fetch the authorization details for ecr: %s", err)
		}

		// Get the valid docker repository name
		repo := getValidECRRepositoryName(repoName, authorizationDetails)

		// New docker client
		dockerClient, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())

		// At the end of this test, destroy all created Docker resources
		defer test_structure.RunTestStage(t, "cleanup_docker", func() {
			if _, err := undeployDocker(dockerClient, repo); err != nil {
				t.Fatalf("An error occurred while deleting the docker image: %s", err)
			}
		})

		if err != nil {
			t.Fatalf("An error occurred while trying to initiate a new docker clientt %s", err)
		}

		dockerBuild(t, repo, "v1")
		dockerPush(t, dockerClient, repo, *authorizationDetails.AuthorizationData[0].AuthorizationToken)
	})
}

// Extracts the ECR repository name from GetAuthorizationTokenOutput
func getValidECRRepositoryName(repoName string, authorizationDetails *ecr.GetAuthorizationTokenOutput) string {
	return strings.Replace(
		fmt.Sprintf(
			"%s/%s",
			goAws.StringValue(authorizationDetails.AuthorizationData[0].ProxyEndpoint),
			repoName),
		"https://", "", -1)
}

// ECR session & authentication
func getAuthorizationDetails(session *session.Session, awsRegion string) (*ecr.GetAuthorizationTokenOutput, error) {
	svc := ecr.New(session, goAws.NewConfig().WithRegion(awsRegion))
	authorizationToken, err := svc.GetAuthorizationToken(&ecr.GetAuthorizationTokenInput{})

	return authorizationToken, err
}

// Build the docker image
func dockerBuild(t *testing.T, repo string, version string) {
	// This text will be passed as an argument to the build image and saved in a txt file
	text := "hello world"

	dockerOptions := &docker.BuildOptions{
		Tags:      []string{fmt.Sprintf("%s:%s", repo, version)},
		BuildArgs: []string{fmt.Sprintf("text=%s", text)},
	}

	docker.Build(t, "./", dockerOptions)
}

// Authenticate with ECR and push the docker image
func dockerPush(t *testing.T, client *client.Client, ecr string, authorizationToken string) {
	// AuthorizationToken is a base64 encoded string in the format of: "<username>:<password>".
	// It seems that ImagePushOptions.RegistryAuth needs to be a base64 encoding of
	// "{ username: <username>, password: <password> }".
	authInfoBytes, _ := base64.StdEncoding.DecodeString(authorizationToken)
	authInfo := strings.Split(string(authInfoBytes), ":")
	auth := struct {
		Username string
		Password string
	}{
		Username: authInfo[0],
		Password: authInfo[1],
	}
	authBytes, _ := json.Marshal(auth)

	out, err := client.ImagePush(
		context.Background(),
		ecr,
		types.ImagePushOptions{
			RegistryAuth: base64.StdEncoding.EncodeToString(authBytes),
			All:          true,
		})

	if err != nil {
		t.Fatalf("An error occurred when trying to push the image to ECR %s", err)
	}

	// nasty workaround, we should write the output line by line as logs
	if _, err := io.Copy(os.Stdout, out); err != nil {
		t.Fatalf("An error occurred while pushing the docker image to ecr: %s", err)
	}

	defer out.Close()
}

// Deploy the example using Terraform
func deployUsingTerraform(t *testing.T, repoName string, awsRegion string, workingDir string) {
	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
			"name":       repoName,
		},
	}

	// Save the Terraform Options struct
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}

// Undeploy the example using Terraform
func undeployTerraform(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	terraform.Destroy(t, terraformOptions)
	test_structure.CleanupTestDataFolder(t, workingDir)
}

// Undeploy docker
func undeployDocker(client *client.Client, image string) ([]types.ImageDeleteResponseItem, error) {
	return client.ImageRemove(context.Background(), image, types.ImageRemoveOptions{})
}
