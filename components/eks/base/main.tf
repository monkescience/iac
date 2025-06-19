resource "aws_eks_cluster" "eks" {
  name     = module.eks_name.name
  role_arn = aws_iam_role.eks.arn
  version  = var.eks_version

  bootstrap_self_managed_addons = false

  upgrade_policy {
    support_type = "EXTENDED"
  }

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.eks_node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs = [
      "79.239.60.71/32"
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSNetworkingPolicy
  ]
}

resource "aws_eks_access_entry" "eks_cluster_admin" {
  for_each = var.eks_cluster_admin_principal_arns

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "example" {
  for_each = var.eks_cluster_admin_principal_arns

  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}
