module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_version = "1.32"
  eks_vpc_id  = "vpc-0e1e0fecc375943f4"
  eks_subnet_ids = [
    "subnet-0b7e23d154c5d295a",
    "subnet-091f240957beae8b8",
    "subnet-0fb7ab3e784260e0c"
  ]
}