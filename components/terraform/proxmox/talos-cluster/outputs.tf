output "vm_id" {
  value = module.talos_vm.vm_id
}

output "mac_addresses" {
  value = module.talos_vm.mac_addresses
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
