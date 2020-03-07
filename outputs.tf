output "repository" {
  description = "repository resource"
  value       = try(aws_ecr_repository.repository[0], null)
}

output "repository_policy" {
  description = "repository policy resource"
  value       = try(aws_ecr_repository_policy.repository_policy[0], null)
}

output "lifecycle_policy" {
  description = "lifecycle policy resource"
  value       = try(aws_ecr_lifecycle_policy.lifecycle_policy[0], null)
}
