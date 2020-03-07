# ---------------------------------------------------------------------------------------------------------------------
# THIS IS A UPPERCASE MAIN HEADLINE
# And it continues with some lowercase information about the module
# We might add more than one line for additional information
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.vpc_id

  accepter {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }
}
