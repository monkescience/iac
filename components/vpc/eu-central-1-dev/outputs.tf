output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.base.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.base.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.base.private_subnet_ids
}

output "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  value       = module.base.private_subnet_cidr_blocks
}
