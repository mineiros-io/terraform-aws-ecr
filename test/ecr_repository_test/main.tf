# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ECR REPOSITORY
# This example creates an ECR repository and grants a newly created IAM User pull and push permissions for the repo.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM ACCESS MANAGEMENT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_user" "docker" {
  name = var.iam_user_name
}

resource "aws_iam_access_key" "docker" {
  user = aws_iam_user.docker.name
}

resource "aws_iam_user_policy" "docker" {
  user   = aws_iam_user.docker.name
  policy = data.aws_iam_policy_document.ecr.json
}

data "aws_iam_policy_document" "ecr" {
  statement {
    sid     = "ECRGetAuthorizationToken"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ECR REPOSITORY
# ---------------------------------------------------------------------------------------------------------------------

module "repository" {
  source = "../.."

  name = var.name

  immutable = var.immutable

  push_identities = [aws_iam_user.docker.arn]
  pull_identities = [aws_iam_user.docker.arn]

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
