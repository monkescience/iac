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
  type = map(object({
    repository_type = string
  }))
  description = "Map of ECR repositories with their types."

  validation {
    condition = alltrue([
      for repo in values(var.ecr_repositories) : contains(["mirror", "private"], repo.repository_type)
    ])
    error_message = "Each repository must have a valid repository_type [mirror, private]."
  }
}