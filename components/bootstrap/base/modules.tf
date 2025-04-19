module "s3_bucket_name" {
  source = "../../../modules/name"

  project     = var.project
  region      = var.region
  environment = var.environment
  name        = "iac-tofu-state"
}