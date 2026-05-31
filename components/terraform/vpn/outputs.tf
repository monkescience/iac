output "public_ip" {
  description = "Public IP address of the WireGuard VPN server"
  value       = module.base.public_ip
}

output "instance_id" {
  description = "Instance ID of the WireGuard VPN server"
  value       = module.base.instance_id
}

output "security_group_id" {
  description = "Security group ID for the WireGuard VPN server"
  value       = module.base.security_group_id
}

output "wireguard_endpoint" {
  description = "WireGuard endpoint (IP:Port) for client configuration"
  value       = module.base.wireguard_endpoint
}
