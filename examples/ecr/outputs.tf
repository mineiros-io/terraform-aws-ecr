output "repository" {
  description = "All outputs of the repository."
  value       = module.repository
}

output "repository_id" {
  description = "The Id of the repository."
  value       = module.repository.repository_id
}

output "repository_arn" {
  description = "The ARN of the repository."
  value       = module.repository.repository_arn
}

output "repository_url" {
  description = "The url of the ECR repository."
  value       = module.repository.repository_url
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
