module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.0"

  cluster_name    = module.eks_name.name
  cluster_version = "1.32"

  # bootstrap_self_managed_addons = false
  cluster_addons = {
    # core_dns               = {}
    # eks-pod-identity-agent = {}
    # cert-manager = {}
    # adot = {}
  }

  vpc_id                   = var.eks_vpc_id
  subnet_ids               = var.eks_subnet_ids
  control_plane_subnet_ids = var.eks_subnet_ids

  # eks_managed_node_groups = {
  #   karpenter = {
  #     ami_type       = "BOTTLEROCKET_ARM_64"
  #     instance_types = ["m6g.large"]
  #
  #     min_size     = 2
  #     max_size     = 4
  #     desired_size = 2
  #
  #     labels = {
  #       # ensure Karpenter runs on nodes that it does not manage
  #       "karpenter.sh/controller" = "true"
  #     }
  #   }
  # }

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

# module "karpenter" {
#   source  = "terraform-aws-modules/eks/aws//modules/karpenter"
#   version = "20.36.0"
#
#   cluster_name = module.eks.cluster_name
#
#   create_node_iam_role = false
#   create_access_entry  = false
#   node_iam_role_arn    = module.eks.eks_managed_node_groups["karpenter"].iam_role_arn
#
#   # attach additional IAM policies to the Karpenter node IAM role
#   node_iam_role_additional_policies = {
#     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }
# }

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "8.0.17"

  depends_on = [module.eks]
}

resource "kubernetes_secret" "argocd_git" {
  metadata {
    name      = "gitops-repository"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url  = "https://github.com/monkescience/gitops"
    name = "gitops"
    # For private repos:
    # username = var.github_username
    # password = var.github_token
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "${var.region}-${var.environment}"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/monkescience/gitops"
        targetRevision = "HEAD"
        path           = "apps/${var.region}-${var.environment}"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_git
  ]
}
