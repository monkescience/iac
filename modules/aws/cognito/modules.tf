module "this" {
  source = "../../shared/name"

  project     = var.project
  region      = var.region
  environment = var.environment
  name        = null
}
