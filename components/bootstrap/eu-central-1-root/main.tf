module "base" {
  source = "../base"

  project     = var.project
  region      = var.region
  environment = var.environment
}