variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_repositories" {
  type        = set(string)
  description = "Set of ECR repository names."
}