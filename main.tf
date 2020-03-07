# ---------------------------------------------------------------------------------------------------------------------
# AWS ECR MODULE
# Create and configure a single ECR repository.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "repository" {
  count = var.module_enabled ? 1 : 0

  name                 = var.name
  image_tag_mutability = var.immutable ? "IMMUTABLE" : "MUTABLE"
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

locals {
  policy_enabled = length(var.repository_policy_statements) > 0 || length(var.push_identities) > 0 || length(var.pull_identities) > 0
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
        for_each = try(statement.value.principals, null)

        content {
          type        = try(principals.value.type, "AWS")
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, null)

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
}

locals {
  lifecycle_policy = jsonencode({
    rules = var.lifecycle_policy_rules
  })
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  count = var.module_enabled && length(var.lifecycle_policy_rules) > 0 ? 1 : 0

  repository = try(aws_ecr_repository.repository[0].name, null)
  policy     = local.lifecycle_policy
}

locals {
  ecr_pull_actions = [
    "ecr:BatchCheckLayerAvailability",
    "ecr:BatchGetImage",
    "ecr:GetAuthorizationToken",
    "ecr:GetDownloadUrlForLayer",
  ]

  ecr_push_only_actions = [
    "ecr:CompleteLayerUpload",
    "ecr:GetAuthorizationToken",
    "ecr:InitiateLayerUpload",
    "ecr:ListImages",
    "ecr:PutImage",
    "ecr:UploadLayerPart",
  ]

  ecr_push_actions = concat(local.ecr_push_only_actions, local.ecr_pull_actions)

  push_statement = length(var.push_identities) > 0 ? [{
    actions     = local.ecr_push_actions
    identifiers = var.push_identities
  }] : []

  pull_statement = length(var.pull_identities) > 0 ? [{
    actions     = local.ecr_pull_actions
    identifiers = var.pull_identities
  }] : []
}
