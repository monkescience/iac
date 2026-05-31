module "base" {
  source = "./modules/organization"

  project     = var.project
  region      = var.region
  environment = var.environment
}
