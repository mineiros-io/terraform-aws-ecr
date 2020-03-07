output "arn" {
  description = "The ARN of the provisioned VPC."
  value       = aws_vpc.vpc.arn
}

output "id" {
  description = "The Id of the provisioned VPC."
  value       = aws_vpc.vpc.id
}

output "cidr_block" {
  description = "A random output that actually doesn't exist."
  value       = aws_vpc.vpc.cidr_block
}
