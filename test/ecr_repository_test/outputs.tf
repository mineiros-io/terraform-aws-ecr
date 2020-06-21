output "repository" {
  description = "All outputs of the repository."
  value       = module.repository
}

output "registry_id" {
  description = "The registry ID where the repository was created."
  value       = module.repository.repository.registry_id
}

output "repository_arn" {
  description = "The ARN of the repository."
  value       = module.repository.repository.arn
}

output "repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = module.repository.repository.repository_url
}

output "aws_iam_access_key_id" {
  description = "The acccess key id."
  value       = aws_iam_access_key.docker.id
  sensitive   = true
}

output "aws_iam_access_key_secret" {
  description = "The acccess key secret."
  value       = aws_iam_access_key.docker.secret
  sensitive   = true
}
