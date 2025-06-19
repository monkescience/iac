module "base" {
  source = "../base"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_version = "1.33"
  eks_subnet_ids = [
    "subnet-048f9754642b3e67c",
    "subnet-091f240957beae8b8",
    "subnet-0aa9585979927b512"
  ]
  eks_cluster_admin_principal_arns = [
    "arn:aws:iam::387105013966:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_admin_dc1b034f828d678b",
  ]
}