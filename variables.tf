# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables.
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "(Required) Name of the repository."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# -------------------------------------------------------------------------------------------------------------------

variable "immutable" {
  type        = bool
  description = "(Optional) You can configure a repository to be immutable to prevent image tags from being overwritten. Defaults to false"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource."
  #
  # Example:
  #
  # tags = {
  #   CreatedAt = "2020-02-07",
  #   Alice     = "Bob
  # }
  #
  default = {}
}

variable "scan_on_push" {
  type        = bool
  description = "(Optional) Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false). Defaults to true"
  default     = true
}

variable "repository_policy_statements" {
  type        = any
  description = "(Optional) A list of repository policy statements."
  default     = []
}

variable "lifecycle_policy_rules" {
  type        = any
  description = "(Optional) List of lifecycle policy rules."
  default     = []
}

variable "pull_identities" {
  type        = list(string)
  description = "(Optional) List of AWS identity identifiers to grant cross account pull access to."
  default     = []
}

variable "push_identities" {
  type        = list(string)
  description = "(Optional) List of AWS identity identifiers to grant cross account push access to."
  default     = []
}

variable "pull_accounts" {
  type        = list(string)
  description = "(Optional) List of AWS Account IDs to grant cross account pull access to."
  default     = []
}

variable "push_accounts" {
  type        = list(string)
  description = "(Optional) List of AWS Account IDs to grant cross account push access to."
  default     = []
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# See https://medium.com/mineiros/the-ultimate-guide-on-how-to-write-terraform-modules-part-1-81f86d31f024
# ----------------------------------------------------------------------------------------------------------------------

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not."
  default     = true
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on."
  default     = []
}

variable "module_tags" {
  description = "(Optional) A map of default tags to apply to all resources created which support tags. Default is {}."
  type        = map(string)
  default     = {}
}
