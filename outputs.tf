output "repository" {
  description = "All outputs of the repository."
  value       = try(aws_ecr_repository.repository[0], null)
}

output "repository_url" {
  description = "The URL of the repository."
  value       = try(aws_ecr_repository.repository[0].repository_url, null)
}

output "repository_arn" {
  description = "The ARN of the repository."
  value       = try(aws_ecr_repository.repository[0].arn, null)
}

output "repository_policy" {
  description = "The attached repository policies."
  value       = try(aws_ecr_repository_policy.repository_policy[0], null)
}

output "lifecycle_policy" {
  description = "The attached repository lifecycle policies."
  value       = try(aws_ecr_lifecycle_policy.lifecycle_policy[0], null)
}
