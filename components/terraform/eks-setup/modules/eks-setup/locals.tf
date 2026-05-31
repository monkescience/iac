locals {
  eks_cluster_oidc_issuer_uri = replace(var.eks_cluster_oidc_issuer_url, "https://", "")
}