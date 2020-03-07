# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "cidr_block" {
  description = "A random variable that is a list without a default value."
  type        = string

  # A string containing a CIDR block
  # See https://docs.aws.amazon.com/vpc/latest/userguide//VPC_Subnets.html for more information
  #
  # Example:
  # cidr_block = "10.0.0.0/16"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "tag" {
  description = "A tag to be applied to the resources of this module."
  type        = string
  default     = "a-tag"
}
