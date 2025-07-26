variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_ecr_public_pull_through_cache" {
  description = "Enable ECR Public pull through cache"
  type        = bool
}

variable "enable_quay_pull_through_cache" {
  description = "Enable Quay pull through cache"
  type        = bool
}

variable "enable_github_pull_through_cache" {
  description = "Enable GitHub Container Registry pull through cache"
  type        = bool
}

variable "enable_dockerhub_pull_through_cache" {
  description = "Enable Docker Hub pull through cache"
  type        = bool
}

variable "enable_gitlab_pull_through_cache" {
  description = "Enable GitLab Container Registry pull through cache"
  type        = bool
}
