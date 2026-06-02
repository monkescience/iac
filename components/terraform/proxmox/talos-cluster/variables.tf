variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_username" {
  type    = string
  default = "root@pam"
}

variable "proxmox_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "proxmox_insecure" {
  type    = bool
  default = true
}

variable "proxmox_ssh_username" {
  type    = string
  default = "root"
}

variable "proxmox_ssh_node_address" {
  type = string
}

variable "node_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "talos_version" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "installer_image" {
  type = string
}

variable "install_disk" {
  type    = string
  default = "/dev/sda"
}

variable "vm_name" {
  type = string
}

variable "vm_id" {
  type    = number
  default = null
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "image_datastore_id" {
  type = string
}

variable "disk_datastore_id" {
  type = string
}

variable "talos_image_url" {
  type = string
}

variable "talos_image_file_name" {
  type = string
}

variable "cpu_cores" {
  type = number
}

variable "cpu_sockets" {
  type    = number
  default = 1
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "memory_mb" {
  type = number
}

variable "disk_size_gb" {
  type = number
}

variable "network_bridge" {
  type = string
}

variable "node_ip" {
  type = string
}

variable "node_ip_cidr" {
  type = string
}

variable "gateway" {
  type = string
}

variable "nameservers" {
  type = list(string)
}

variable "network_interface" {
  type    = string
  default = "eth0"
}

variable "started" {
  type    = bool
  default = true
}

variable "on_boot" {
  type    = bool
  default = true
}

# tflint-ignore: terraform_unused_declarations
variable "component" {
  type = string
}

# tflint-ignore: terraform_unused_declarations
variable "namespace" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "tenant" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "environment" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "stage" {
  type    = string
  default = null
}

# tflint-ignore: terraform_unused_declarations
variable "project" {
  type    = string
  default = null
}
