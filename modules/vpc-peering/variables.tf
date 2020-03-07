# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "peer_owner_id" {
  description = "The AWS account ID of the owner of the peer VPC."
  type        = string
}

variable "peer_vpc_id" {
  description = "The ID of the VPC with which you are creating the VPC Peering Connection."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the requester VPC."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "allow_remote_vpc_dns_resolution" {
  description = "Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC. This is not supported for inter-region VPC peering."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to the VPC Peering Connection. The key is the tag name and the value is the tag value. Note that the tag 'Name' is automatically added by this module but may be optionally overwritten by this variable."
  type        = map(string)
  default     = {}
}
