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

variable "acm_cert_arn" {
  description = "ACM Certificate ARN for the domain"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for the domain"
  type        = string
}

variable "cognito_user_pool_endpoint" {
  description = "Cognito User Pool endpoint for authentication"
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID for authentication"
  type        = string
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
