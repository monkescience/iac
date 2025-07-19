module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  github_domain            = "token.actions.githubusercontent.com"
  mirror_github_repository = "monkescience/mirror"
  mirror_ecr_repository_arns = [
    "arn:aws:ecr:eu-central-1:387105013966:repository/argoproj/argocd"
  ]
}