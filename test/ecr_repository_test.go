package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestECRRepository(t *testing.T) {
	t.Parallel()

	tag := "mineiros-io/test-image:v1"
	text := "hello world"

	dockerOptions := &docker.BuildOptions{
		Tags:      []string{tag},
		BuildArgs: []string{fmt.Sprintf("text=%s", text)},
	}

	docker.Build(t, "./", dockerOptions)

	awsRegion := aws.GetRandomRegion(t, nil, nil)
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/ecr",
		Upgrade:      true,
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
