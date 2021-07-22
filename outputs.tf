# ------------------------------------------------------------------------------
# OUTPUT CALCULATED VARIABLES (prefer full objects)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OUTPUT ALL RESOURCES AS FULL OBJECTS
# ------------------------------------------------------------------------------

output "repository" {
  description = "All outputs of the repository."
  value       = try(aws_ecr_repository.repository[0], null)
}

output "repository_policy" {
  description = "The attached repository policies."
  value       = try(aws_ecr_repository_policy.repository_policy[0], null)
}

output "lifecycle_policy" {
  description = "The attached repository lifecycle policies."
  value       = try(aws_ecr_lifecycle_policy.lifecycle_policy[0], null)
}

# ------------------------------------------------------------------------------
# OUTPUT ALL INPUT VARIABLES
# -----------------------------------------------------------------------------

output "module_inputs" {
  description = "A map of all module arguments. Omitted optional arguments will be represented with their actual defaults."
  value = {
    name                         = var.name
    immutable                    = var.immutable
    scan_on_push                 = var.scan_on_push
    repository_policy_statements = var.repository_policy_statements
    lifecycle_policy_rules       = var.lifecycle_policy_rules
    pull_identities              = var.pull_identities
    push_identities              = var.push_identities
    tags                         = var.tags
  }
}

# ------------------------------------------------------------------------------
# OUTPUT MODULE CONFIGURATION
# ------------------------------------------------------------------------------

output "module_enabled" {
  description = "Whether the module is enabled"
  value       = var.module_enabled
}

output "module_depends_on" {
  description = "A list of external resources the module depends_on."
  value       = var.module_depends_on
}

output "module_tags" {
  description = "A map of default tags to apply to all resources created which support tags."
  value       = var.module_tags
}
