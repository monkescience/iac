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
  description = "The ID of the VPC where the private domain will be created"
  type        = string
}
