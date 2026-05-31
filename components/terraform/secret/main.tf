module "base" {
  source = "./modules/secret"

  region      = var.region
  environment = var.environment
  project     = var.project
}
