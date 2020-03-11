output "repository" {
  value = module.repository
}

output "repository_url" {
  description = "The url of the ECR repository."
  value       = module.repository.repository_url
}
