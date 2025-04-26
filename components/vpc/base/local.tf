locals {
  public_subnets_map = tomap({
    for subnet in var.public_subnets :
    "${subnet.availability_zone}#${subnet.cidr_block}" => subnet
  })

  private_subnets_map = tomap({
    for subnet in var.private_subnets :
    "${subnet.availability_zone}#${subnet.cidr_block}" => subnet
  })
}