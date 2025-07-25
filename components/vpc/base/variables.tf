variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "enable_fck_nat" {
  description = "Whether to create FCK NAT gateways for private subnets to access the internet"
  type        = bool
}

variable "enable_nat_gateways" {
  description = "Whether to create NAT gateways for private subnets to access the internet"
  type        = bool
}

variable "enable_ecr_vpc_endpoints" {
  description = "Whether to create VPC endpoints for ECR in the VPC"
  type        = bool
}
