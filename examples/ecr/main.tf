# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ECR REPOSITORY
# This example creates an ECR repository and attach a lifecycle policy.
# ---------------------------------------------------------------------------------------------------------------------

module "repository" {
  source  = "mineiros-io/ecr/aws"
  version = "~> 0.1.3"

  name = "example"

  immutable = true

  push_identities = []
  pull_identities = []

  lifecycle_policy_rules = [
    {
      rulePriority : 1,
      description : "Expire untagged images older than 90 days",
      selection : {
        tagStatus : "untagged",
        countType : "sinceImagePushed",
        countUnit : "days",
        countNumber : 90
      },
      action : {
        type : "expire"
      }
    },
    {
      rulePriority : 2,
      description : "Only keep the most recent 20 images",
      selection : {
        tagStatus : "any",
        countType : "imageCountMoreThan",
        countNumber : 20
      },
      action : {
        type : "expire"
      }
    }
  ]
}

# ------------------------------------------------------------------------------
# EXAMPLE PROVIDER CONFIGURATION
# ------------------------------------------------------------------------------

provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

# ------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES:
# ------------------------------------------------------------------------------
# You can provide your credentials via the
#   AWS_ACCESS_KEY_ID and
#   AWS_SECRET_ACCESS_KEY, environment variables,
# representing your AWS Access Key and AWS Secret Key, respectively.
# Note that setting your AWS credentials using either these (or legacy)
# environment variables will override the use of
#   AWS_SHARED_CREDENTIALS_FILE and
#   AWS_PROFILE.
# The
#   AWS_DEFAULT_REGION and
#   AWS_SESSION_TOKEN environment variables are also used, if applicable.
# ------------------------------------------------------------------------------
