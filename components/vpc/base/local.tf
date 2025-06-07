locals {
  public_subnets_map = tomap({
    for subnet in var.public_subnets :
    "${subnet.availability_zone}#${subnet.cidr_block}" => subnet
  })

  private_subnets_map = tomap({
    for subnet in var.private_subnets :
    "${subnet.availability_zone}#${subnet.cidr_block}" => subnet
  })

  # Map each AZ to its corresponding public subnet key
  availability_zone_to_public_subnets_map = {
    for key, value in aws_subnet.public : value.availability_zone => key
  }
}