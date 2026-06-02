variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "Managed by OpenTofu"
}

variable "node_name" {
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

variable "machine_config" {
  type      = string
  sensitive = true
}

variable "machine_config_file_name" {
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

variable "ip_address" {
  type = string
}

variable "gateway" {
  type = string
}

variable "nameservers" {
  type = list(string)
}

variable "started" {
  type    = bool
  default = true
}

variable "on_boot" {
  type    = bool
  default = true
}
