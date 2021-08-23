# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE AND MANAGE AN AMAZON ELASTIC CONTAINER REGISTRY (ECR) ON AMAZON WEB SERVICES (AWS)
# This module is used to launch and manage an private docker repository with ECR and includes:
# - ECR Repositories
# - Repository Policies
# - Lifecycle Policies
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ECR REPOSITORY
# An ECR Repository is a private docker repository that can contain multiple version and tags of an image.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "repository" {
  count = var.module_enabled ? 1 : 0

  name                 = var.name
  image_tag_mutability = var.immutable ? "IMMUTABLE" : "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags       = merge(var.module_tags, var.tags)
  depends_on = [var.module_depends_on]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE REPOSITORY POLICIES
# Amazon ECR uses resource-based permissions to control access to repositories. Resource-based permissions let you
# specify which IAM users or roles have access to a repository and what actions they can perform on it. By default,
# only the repository owner has access to a repository. You can apply a policy document that allow additional
# permissions to your repository.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  policy_enabled = length(var.repository_policy_statements) > 0 || length(var.push_identities) > 0 || length(var.pull_identities) > 0

  ecr_pull_actions = [
    "ecr:BatchCheckLayerAvailability",
    "ecr:BatchGetImage",
    "ecr:GetDownloadUrlForLayer",
  ]

  ecr_push_actions = [
    "ecr:BatchCheckLayerAvailability",
    "ecr:CompleteLayerUpload",
    "ecr:InitiateLayerUpload",
    "ecr:ListImages",
    "ecr:PutImage",
    "ecr:UploadLayerPart",
  ]

  push_statement = length(var.push_identities) > 0 ? [{
    actions     = local.ecr_push_actions
    identifiers = var.push_identities
  }] : []

  pull_statement = length(var.pull_identities) > 0 ? [{
    actions     = local.ecr_pull_actions
    identifiers = var.pull_identities
  }] : []
}

data "aws_iam_policy_document" "policy" {
  count = var.module_enabled && local.policy_enabled ? 1 : 0

  dynamic "statement" {
    for_each = var.repository_policy_statements

    content {
      actions = try(statement.value.actions, null)
      effect  = try(statement.value.effect, null)
      sid     = try(statement.value.sid, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = try(principals.value.type, "AWS")
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = try(not_principals.value.type, "AWS")
          identifiers = not_principals.value.identifiers
        }
      }
    }
  }

  dynamic "statement" {
    for_each = concat(local.pull_statement, local.push_statement)

    content {
      actions = statement.value.actions
      effect  = "Allow"
      principals {
        type        = "AWS"
        identifiers = statement.value.identifiers
      }
    }
  }
}

resource "aws_ecr_repository_policy" "repository_policy" {
  count = var.module_enabled && local.policy_enabled ? 1 : 0

  repository = try(aws_ecr_repository.repository[0].name, null)
  policy     = join("", data.aws_iam_policy_document.policy.*.json)

  depends_on = [var.module_depends_on]
}

locals {
  lifecycle_policy = jsonencode({
    rules = var.lifecycle_policy_rules
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ECR LIFECYCLE POLICIES
# ECR lifecycle policies enable you to specify the lifecycle management of images in a repository.
# A lifecycle policy is a set of one or more rules, where each rule defines an action for Amazon ECR.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  count = var.module_enabled && length(var.lifecycle_policy_rules) > 0 ? 1 : 0

  repository = try(aws_ecr_repository.repository[0].name, null)
  policy     = local.lifecycle_policy

  depends_on = [var.module_depends_on]
}

