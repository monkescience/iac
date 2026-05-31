module "ecr-pull-though-cache" {
  source = "../../../../modules/aws/ecr-pull-though-cache"

  enable_quay_pull_through_cache       = var.enable_quay_pull_through_cache
  enable_ecr_public_pull_through_cache = var.enable_ecr_public_pull_through_cache
  enable_dockerhub_pull_through_cache  = var.enable_dockerhub_pull_through_cache
  enable_github_pull_through_cache     = var.enable_github_pull_through_cache
  enable_gitlab_pull_through_cache     = var.enable_gitlab_pull_through_cache
}
