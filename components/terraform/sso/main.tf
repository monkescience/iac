module "base" {
  source = "./modules/sso"

  region      = var.region
  environment = var.environment
}
