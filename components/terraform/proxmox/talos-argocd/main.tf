locals {
  gitops_raw_base_url = "https://raw.githubusercontent.com/${var.gitops_repository}/refs/heads/${var.gitops_target_revision}"
}

data "http" "argocd_values" {
  url = "${local.gitops_raw_base_url}/manifests/argocd/${var.cluster_name}/values.yaml"
}

data "http" "argocd_root_app" {
  url = "${local.gitops_raw_base_url}/apps/${var.cluster_name}.yaml"
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_chart_version
  wait             = true
  timeout          = 600

  values = [data.http.argocd_values.response_body]

  lifecycle {
    ignore_changes = all
  }
}

resource "kubectl_manifest" "argocd_root_app" {
  yaml_body = data.http.argocd_root_app.response_body

  depends_on = [helm_release.argocd]
}
