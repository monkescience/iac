module "organization" {
  source = "../../../../modules/aws/organization"

  project     = var.project
  region      = var.region
  environment = var.environment
}
