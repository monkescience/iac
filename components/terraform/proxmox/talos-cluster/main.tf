resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_endpoint   = var.cluster_endpoint
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  machine_type       = "controlplane"
  talos_version      = var.talos_version

  config_patches = [
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
      machine = {
        install = {
          disk  = var.install_disk
          image = var.installer_image
        }
        network = {
          interfaces = [
            {
              interface = var.network_interface
              addresses = [var.node_ip_cidr]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.gateway
                }
              ]
            }
          ]
          nameservers = var.nameservers
        }
      }
    })
  ]
}

module "talos_vm" {
  source = "../../../../modules/proxmox/talos-vm"

  name                     = var.vm_name
  node_name                = var.node_name
  vm_id                    = var.vm_id
  tags                     = var.tags
  image_datastore_id       = var.image_datastore_id
  disk_datastore_id        = var.disk_datastore_id
  talos_image_url          = var.talos_image_url
  talos_image_file_name    = var.talos_image_file_name
  machine_config           = data.talos_machine_configuration.controlplane.machine_configuration
  machine_config_file_name = "${var.vm_name}-talos.yaml"
  cpu_cores                = var.cpu_cores
  cpu_sockets              = var.cpu_sockets
  cpu_type                 = var.cpu_type
  memory_mb                = var.memory_mb
  disk_size_gb             = var.disk_size_gb
  network_bridge           = var.network_bridge
  ip_address               = var.node_ip_cidr
  gateway                  = var.gateway
  nameservers              = var.nameservers
  started                  = var.started
  on_boot                  = var.on_boot
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.node_ip]
  nodes                = [var.node_ip]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [module.talos_vm]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_ip

  timeouts = {
    create = "30m"
  }
}

data "talos_cluster_health" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = [var.node_ip]
  endpoints            = [var.node_ip]

  timeouts = {
    read = "30m"
  }
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [data.talos_cluster_health.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_ip

  timeouts = {
    create = "10m"
    update = "10m"
  }
}
