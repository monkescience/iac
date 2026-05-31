variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the vpn server will be deployed"
  type        = string
}

variable "vpc_public_subnet" {
  description = "The public subnet in the VPC where the vpn server will be deployed"
  type        = string
}
