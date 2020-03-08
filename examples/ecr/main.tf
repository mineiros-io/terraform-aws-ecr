# ---------------------------------------------------------------------------------------------------------------------
# Create an ECR repository and grant cross account pull and push to random accounts
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  version = "~> 2.45"
  region  = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "repository" {
  source = "../.."

  name = "repository"

  immutable = true

  push_identities = [data.aws_caller_identity.current.arn]
  pull_identities = [data.aws_caller_identity.current.arn]
}
