module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  enable_quay_pull_through_cache       = true
  enable_ecr_public_pull_through_cache = true
  enable_dockerhub_pull_through_cache  = false
  enable_github_pull_through_cache     = false
  enable_gitlab_pull_through_cache     = false
}