# Karpenter resources
resource "kubectl_manifest" "eks_node_class" {
  yaml_body = templatefile("${path.module}/eks-node-class.yaml", {
    region             = var.region
    environment        = var.environment
    eks_node_role_name = var.eks_node_role_name
    eks_security_group = var.eks_security_group
    eks_subnet_ids     = var.eks_subnet_ids
  })
}

resource "kubectl_manifest" "eks_node_pool" {
  yaml_body = file("${path.module}/eks-node-pool.yaml")
}

# ArgoCD Resources
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "8.1.2"
  wait             = true
  timeout          = 600


  values = [file("${path.module}/argocd-config.yaml")]

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    kubectl_manifest.eks_node_class,
    kubectl_manifest.eks_node_pool
  ]
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

resource "kubectl_manifest" "argocd_root_app" {
  yaml_body = templatefile("${path.module}/argocd-root-app.yaml", {
    region      = var.region
    environment = var.environment
  })

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_git
  ]
}
