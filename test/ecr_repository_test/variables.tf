# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT PARAMETERS
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMTERS
# These variables have defaults, but may be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to deploy the example in."
  type        = string
  default     = "us-east-1"
}

variable "iam_user_name" {
  description = "The name of the IAM User."
  type        = string
  default     = "docker"
}

variable "name" {
  description = "The name of the ECR repository."
  type        = string
  default     = "example"
}

variable "immutable" {
  description = "(Optional) You can configure a repository to be immutable to prevent image tags from being overwritten. Defaults to true"
  type        = bool
  default     = true
}
