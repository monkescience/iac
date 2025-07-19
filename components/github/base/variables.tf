variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "github_domain" {
  type        = string
  description = "GitHub Actions domain for OIDC"
}

variable "mirror_github_repository" {
  type        = string
  description = "Mirror GitHub repository"
}

variable "mirror_ecr_repository_arns" {
  type        = list(string)
  description = "List of Mirror ECR repository ARNs"
}
