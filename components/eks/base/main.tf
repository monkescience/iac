module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.0"

  cluster_name           = module.eks_name.name
  cluster_version        = var.eks_version
  cluster_upgrade_policy = "EXTENDED"

  vpc_id                   = var.eks_vpc_id
  subnet_ids               = var.eks_subnet_ids
  control_plane_subnet_ids = var.eks_subnet_ids

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = true

  cluster_endpoint_public_access_cidrs = [
    "79.239.60.71/32"
  ]

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }
}
