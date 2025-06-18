module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_version = "1.33"
  eks_vpc_id  = "vpc-0e1e0fecc375943f4"
  eks_subnet_ids = [
    "subnet-048f9754642b3e67c",
    "subnet-091f240957beae8b8",
    "subnet-0aa9585979927b512"
  ]
}