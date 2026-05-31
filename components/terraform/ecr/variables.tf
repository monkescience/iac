variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "component" {
  type = string
}

variable "ecr_repositories" {
  type        = set(string)
  description = "Set of ECR repository names."
}

# tflint-ignore: terraform_unused_declarations
variable "namespace" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "tenant" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "stage" {
  type    = string
  default = null
}
