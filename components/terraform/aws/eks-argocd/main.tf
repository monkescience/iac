data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "eks/terraform.tfstate"
    region = var.region
  }
}

module "eks-argocd" {
  source = "../../../../modules/aws/eks-argocd"

  region      = var.region
  environment = var.environment
}
