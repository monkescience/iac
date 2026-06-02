data "terraform_remote_state" "talos_cluster" {
  backend = "local"

  config = {
    path = var.talos_cluster_state_path
  }
}

locals {
  kubeconfig = yamldecode(data.terraform_remote_state.talos_cluster.outputs.kubeconfig)

  kubernetes_host                   = local.kubeconfig.clusters[0].cluster.server
  kubernetes_cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
  kubernetes_client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
  kubernetes_client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
}

provider "kubectl" {
  host                   = local.kubernetes_host
  cluster_ca_certificate = local.kubernetes_cluster_ca_certificate
  client_certificate     = local.kubernetes_client_certificate
  client_key             = local.kubernetes_client_key
  load_config_file       = false
}

provider "helm" {
  kubernetes = {
    host                   = local.kubernetes_host
    cluster_ca_certificate = local.kubernetes_cluster_ca_certificate
    client_certificate     = local.kubernetes_client_certificate
    client_key             = local.kubernetes_client_key
  }
}
