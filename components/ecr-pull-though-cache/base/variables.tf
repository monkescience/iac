variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_quay_pull_through_cache" {
  description = "Enable Quay pull through cache"
  type        = bool
}

variable "enable_github_pull_through_cache" {
  description = "Enable GitHub pull through cache"
  type        = bool
}

variable "enable_dockerhub_pull_through_cache" {
  description = "Enable DockerHub pull through cache"
  type        = bool
}

variable "enable_gitlab_pull_through_cache" {
  description = "Enable GitLab pull through cache"
  type        = bool
}
