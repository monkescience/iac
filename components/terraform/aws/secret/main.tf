module "secret" {
  source = "../../../../modules/aws/secret"

  region      = var.region
  environment = var.environment
  project     = var.project
}
