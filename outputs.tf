output "vpc_id" {
  description = "The VPCs ID."
  value       = module.vpc.id
}

output "vpc_arn" {
  description = "The VPCs ARN."
  value       = module.vpc.arn
}
