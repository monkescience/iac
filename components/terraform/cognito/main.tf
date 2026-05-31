module "base" {
  source = "./modules/cognito"

  region      = var.region
  environment = var.environment
  project     = var.project
}
