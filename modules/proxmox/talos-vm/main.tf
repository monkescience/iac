resource "proxmox_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name

  decompression_algorithm = "zst"
  file_name               = var.talos_image_file_name
  url                     = var.talos_image_url
}

resource "proxmox_virtual_environment_file" "machine_config" {
  content_type = "snippets"
  datastore_id = var.image_datastore_id
  node_name    = var.node_name

  source_raw {
    data      = var.machine_config
    file_name = var.machine_config_file_name
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = var.description
  node_name   = var.node_name
  vm_id       = var.vm_id
  tags        = var.tags

  bios            = "ovmf"
  boot_order      = ["scsi0"]
  machine         = "q35"
  on_boot         = var.on_boot
  scsi_hardware   = "virtio-scsi-pci"
  started         = var.started
  stop_on_destroy = true

  cpu {
    cores   = var.cpu_cores
    sockets = var.cpu_sockets
    type    = var.cpu_type
  }

  efi_disk {
    datastore_id      = var.disk_datastore_id
    file_format       = "raw"
    pre_enrolled_keys = false
    type              = "4m"
  }

  initialization {
    datastore_id      = var.disk_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.machine_config.id

    dns {
      servers = var.nameservers
    }

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.disk_datastore_id
    discard      = "on"
    file_id      = proxmox_download_file.talos_image.id
    interface    = "scsi0"
    size         = var.disk_size_gb
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  vga {
    type = "serial0"
  }
}
