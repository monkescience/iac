variable "owner" {
  type        = string
  description = "GitHub organization or user name."
}

# tflint-ignore: terraform_unused_declarations
variable "namespace" {
  type        = string
  description = "Atmos namespace."
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "tenant" {
  type        = string
  description = "Atmos tenant."
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "environment" {
  type        = string
  description = "Atmos environment."
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "stage" {
  type        = string
  description = "Atmos stage."
  default     = null
}
