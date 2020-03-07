# ---------------------------------------------------------------------------------------------------------------------
# THIS IS A UPPERCASE MAIN HEADLINE
# And it continues with some lowercase information about the module
# We might add more than one line for additional information
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
}

# ---------------------------------------------------------------------------------------------------------------------
# Another normal headline that describes the following resource
# ---------------------------------------------------------------------------------------------------------------------

locals {}
