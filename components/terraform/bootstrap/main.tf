module "base" {
  source = "./modules/bootstrap"

  project     = var.project
  region      = var.region
  environment = var.environment
}
