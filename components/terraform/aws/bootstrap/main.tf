module "bootstrap" {
  source = "../../../../modules/aws/bootstrap"

  project     = var.project
  region      = var.region
  environment = var.environment
}
