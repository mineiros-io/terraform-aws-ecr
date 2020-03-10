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

  lifecycle_policy_rules = [
    {
      rulePriority : 1,
      description : "Expire images older than 90 days",
      selection : {
        tagStatus : "any",
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
