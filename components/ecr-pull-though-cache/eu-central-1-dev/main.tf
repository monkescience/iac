module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  enable_dockerhub_pull_through_cache = true
  enable_github_pull_through_cache    = true
  enable_gitlab_pull_through_cache    = true
  enable_quay_pull_through_cache      = true
}