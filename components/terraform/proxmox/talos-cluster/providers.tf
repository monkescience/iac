provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure
  username = var.proxmox_username
  password = var.proxmox_password

  ssh {
    username = var.proxmox_ssh_username
    password = var.proxmox_password

    node {
      name    = var.node_name
      address = var.proxmox_ssh_node_address
    }
  }
}
