output "public_ip" {
  description = "Public IP address of the WireGuard VPN server"
  value       = module.vpn.public_ip
}

output "instance_id" {
  description = "Instance ID of the WireGuard VPN server"
  value       = module.vpn.instance_id
}

output "security_group_id" {
  description = "Security group ID for the WireGuard VPN server"
  value       = module.vpn.security_group_id
}

output "wireguard_endpoint" {
  description = "WireGuard endpoint (IP:Port) for client configuration"
  value       = module.vpn.wireguard_endpoint
}
