variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "eks_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for the domain"
  type        = string
}

variable "acm_cert_arn" {
  description = "ACM Certificate ARN for the domain"
  type        = string
}

variable "load_balancer_arn" {
  description = "ARN of the AWS Load Balancer to route to"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID of the EKS cluster"
  type        = string
}

variable "vpc_cidr_blocks" {
  description = "List of CIDR blocks for the VPC"
  type        = list(string)
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID for authentication"
  type        = string
}

variable "cognito_user_pool_endpoint" {
  description = "Cognito User Pool endpoint for authentication"
  type        = string
}
