module "github-oidc" {
  source = "../../../../modules/aws/github-oidc"

  region      = var.region
  environment = var.environment
  project     = var.project

  github_domain              = var.github_domain
  mirror_enabled             = var.mirror_enabled
  mirror_github_repository   = var.mirror_github_repository
  mirror_ecr_repository_arns = var.mirror_ecr_repository_arns
}
