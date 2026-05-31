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

variable "route53_zone_id" {
  type        = string
  description = "The ID of the Route 53 hosted zone where the EKS cluster will be registered"
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
