module "cognito" {
  source = "../../../../modules/aws/cognito"

  region      = var.region
  environment = var.environment
  project     = var.project
}
