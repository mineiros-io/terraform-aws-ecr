# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ECR REPOSITORY AND GRANT CROSS ACCOUNT PULL AND PUSH TO THE CURRENTLY USED ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  version = "~> 2.45"
  region  = var.aws_region
}

data "aws_caller_identity" "current" {}

module "repository" {
  source = "../.."

  name = var.name

  immutable = var.immutable

  push_identities = [data.aws_caller_identity.current.arn]
  pull_identities = [data.aws_caller_identity.current.arn]
}
