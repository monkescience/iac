module "base" {
  source = "./modules/ecr"

  region      = var.region
  environment = var.environment

  ecr_repositories = var.ecr_repositories
}
