output "id" {
  description = "The ID of the VPC Peering Connection."
  value       = aws_vpc_peering_connection.vpc_peering.id
}

output "accept_status" {
  description = "The status of the VPC Peering Connection request."
  value       = aws_vpc_peering_connection.vpc_peering.accept_status
}
