module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  ecr_repositories = {
    "argoproj/argocd" = {
      repository_type = "mirror"
    },
    "monkescience/reference-service-go" = {
      repository_type = "private"
    }
  }
}