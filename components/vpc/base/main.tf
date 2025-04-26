resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = true

  tags = {
    Name = module.vpc_name.name
  }
}

resource "aws_default_route_table" "vpc" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "${module.vpc_name.name}-default"
  }
}

resource "aws_default_network_acl" "vpc" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  subnet_ids = concat(
    [for subnet in aws_subnet.public : subnet.id],
    [for subnet in aws_subnet.private : subnet.id]
  )

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${module.vpc_name.name}-default"
  }
}

resource "aws_default_security_group" "vpc" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow all traffic within the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${module.vpc_name.name}-default"
  }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${module.vpc_name.name}-public"
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets_map

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${module.vpc_name.name}-public-${each.value.availability_zone}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc.id
  }

  tags = {
    Name = "${module.vpc_name.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets_map

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${module.vpc_name.name}-private-${each.value.availability_zone}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${module.vpc_name.name}-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Commented out because $$$$$$
# resource "aws_eip" "private" {
#   for_each = aws_subnet.private
#
#   domain = "vpc"
# }
#
# resource "aws_nat_gateway" "private" {
#   for_each = aws_subnet.private
#
#   allocation_id = aws_eip.private[each.key].id
#   subnet_id     = each.value.id
# }
#
# resource "aws_route_table" "private_internet" {
#   for_each = aws_nat_gateway.private
#
#   vpc_id = aws_vpc.vpc.id
#
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = each.value.id
#   }
# }
#
# resource "aws_route_table_association" "private_internet" {
#   for_each = aws_subnet.private
#
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.private_internet[each.key].id
# }
