output "public_ip" {
  description = "Public IP address of the WireGuard VPN server"
  value       = aws_instance.vpn.public_ip
}

output "instance_id" {
  description = "Instance ID of the WireGuard VPN server"
  value       = aws_instance.vpn.id
}

output "security_group_id" {
  description = "Security group ID for the WireGuard VPN server"
  value       = aws_security_group.vpn.id
}

output "wireguard_endpoint" {
  description = "WireGuard endpoint (IP:Port) for client configuration"
  value       = "${aws_instance.vpn.public_ip}:51820"
}
