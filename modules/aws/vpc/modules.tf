module "vpc_name" {
  source = "../../shared/name"

  project     = var.project
  region      = var.region
  environment = var.environment
  name        = "main"
}
