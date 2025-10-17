# ArgoCD Resources
data "http" "argocd_config" {
  url = "https://raw.githubusercontent.com/monkescience/gitops/refs/heads/main/manifests/argocd/eu-central-1-dev/values.yaml"
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "8.6.3"
  wait             = true
  timeout          = 600

  values = [data.http.argocd_config.response_body]

  lifecycle {
    ignore_changes = all
  }
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
