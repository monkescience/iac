# Quay Container Registry
resource "aws_ecr_pull_through_cache_rule" "quay" {
  count = var.enable_quay_pull_through_cache ? 1 : 0

  ecr_repository_prefix = "quay"
  upstream_registry_url = "quay.io"
}

# Amazon ECR Public
resource "aws_ecr_pull_through_cache_rule" "ecr_public" {
  count = var.enable_ecr_public_pull_through_cache ? 1 : 0

  ecr_repository_prefix = "ecr-public"
  upstream_registry_url = "public.ecr.aws"
}

# GitHub Container Registry
resource "aws_secretsmanager_secret" "github" {
  count = var.enable_github_pull_through_cache ? 1 : 0

  name                    = "ecr-pullthroughcache/github"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "github" {
  count = var.enable_github_pull_through_cache ? 1 : 0

  secret_id = aws_secretsmanager_secret.github[0].id
  secret_string = jsonencode({
    username    = "YOUR_GITHUB_USERNAME"
    accessToken = "YOUR_GHCR_PAT"
  })
  version_stages = ["AWSCURRENT"]

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_ecr_pull_through_cache_rule" "github" {
  count = var.enable_github_pull_through_cache ? 1 : 0

  ecr_repository_prefix = "github"
  upstream_registry_url = "ghcr.io"
  credential_arn        = aws_secretsmanager_secret.github[0].arn
}

# Docker Container Registry
resource "aws_secretsmanager_secret" "dockerhub" {
  count = var.enable_dockerhub_pull_through_cache ? 1 : 0

  name                    = "ecr-pullthroughcache/dockerhub"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "dockerhub" {
  count = var.enable_dockerhub_pull_through_cache ? 1 : 0

  secret_id = aws_secretsmanager_secret.dockerhub[0].id
  secret_string = jsonencode({
    username    = "YOUR_DOCKERHUB_USERNAME"
    accessToken = "YOUR_DOCKERHUB_TOKEN"
  })
  version_stages = ["AWSCURRENT"]

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_ecr_pull_through_cache_rule" "dockerhub" {
  count = var.enable_dockerhub_pull_through_cache ? 1 : 0

  ecr_repository_prefix = "dockerhub"
  upstream_registry_url = "registry-1.docker.io"
  credential_arn        = aws_secretsmanager_secret.dockerhub[0].arn
}

# Gitlab Container Registry
resource "aws_secretsmanager_secret" "gitlab" {
  count = var.enable_gitlab_pull_through_cache ? 1 : 0

  name                    = "ecr-pullthroughcache/gitlab"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "gitlab" {
  count = var.enable_gitlab_pull_through_cache ? 1 : 0

  secret_id = aws_secretsmanager_secret.gitlab[0].id
  secret_string = jsonencode({
    username    = "YOUR_GITLAB_USERNAME"
    accessToken = "YOUR_GITLAB_TOKEN"
  })
  version_stages = ["AWSCURRENT"]

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_ecr_pull_through_cache_rule" "gitlab" {
  count = var.enable_gitlab_pull_through_cache ? 1 : 0

  ecr_repository_prefix = "gitlab"
  upstream_registry_url = "registry.gitlab.com"
  credential_arn        = aws_secretsmanager_secret.gitlab[0].arn
}

# Pull Through Cache Lifecycle Policy
data "aws_ecr_lifecycle_policy_document" "template" {
  rule {
    priority    = 1
    description = "Keep only the latest 2 images from the upstream registry"

    selection {
      count_number = 2
      count_type   = "imageCountMoreThan"
      tag_status   = "any"
    }

    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_repository_creation_template" "template" {
  prefix               = "ROOT"
  description          = "Pull Through Cache Repository for ECR"
  image_tag_mutability = "IMMUTABLE"
  applied_for          = ["PULL_THROUGH_CACHE"]
  lifecycle_policy     = data.aws_ecr_lifecycle_policy_document.template.json

  encryption_configuration {
    encryption_type = "AES256"
  }
}