data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

# Grant cluster-admin to the SSO "admin" permission set provisioned in this account.
# Resolved dynamically so a rebuild picks up the new AWSReservedSSO_admin_<suffix> role
# (the suffix and account id are not stable across rebuilds).
data "aws_iam_roles" "sso_admin" {
  name_regex  = "AWSReservedSSO_admin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

module "eks" {
  source = "../../../../modules/aws/eks"

  region      = var.region
  environment = var.environment
  project     = var.project

  eks_version                      = var.eks_version
  eks_subnet_ids                   = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  eks_cluster_admin_principal_arns = data.aws_iam_roles.sso_admin.arns
  eks_public_access_cidrs          = var.eks_public_access_cidrs
}
