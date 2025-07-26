module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  ecr_repositories = [
    "monkescience/reference-service-go"
  ]
}