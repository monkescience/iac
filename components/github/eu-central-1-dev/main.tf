module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  github_domain              = "token.actions.githubusercontent.com"
  mirror_enabled             = false
  mirror_github_repository   = "monkescience/mirror"
  mirror_ecr_repository_arns = []
}