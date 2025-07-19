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

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${module.vpc_name.name}-public-${each.value.availability_zone}"
  }
}

resource "aws_route_table" "public" {
  for_each = aws_subnet.public

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc.id
  }

  tags = {
    Name = "${module.vpc_name.name}-public-${each.value.availability_zone}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
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

# FCK NAT Gateway resources - can be enabled/disabled with var.enable_fck_nat
resource "aws_security_group" "fck_nat" {
  count = var.enable_fck_nat ? 1 : 0

  name        = "${module.vpc_name.name}-fck-nat-sg"
  description = "Security group for FCK-NAT instances"
  vpc_id      = aws_vpc.vpc.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all inbound traffic from the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = {
    Name = "${module.vpc_name.name}-fck-nat-sg"
  }
}

data "aws_ami" "amazon_linux_2" {
  count = var.enable_fck_nat ? 1 : 0

  most_recent = true
  owners      = ["568608671756"]

  filter {
    name   = "name"
    values = ["fck-nat-al2023-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_network_interface" "private_fck_nat" {
  for_each = var.enable_fck_nat ? aws_subnet.public : {}

  subnet_id         = each.value.id
  security_groups   = [aws_security_group.fck_nat[0].id]
  source_dest_check = false

  tags = {
    Name = "${module.vpc_name.name}-fck-nat-eni-${each.value.availability_zone}"
  }
}

resource "aws_instance" "private_fck_nat" {
  for_each = var.enable_fck_nat ? aws_network_interface.private_fck_nat : {}

  ami           = data.aws_ami.amazon_linux_2[0].id
  instance_type = "t4g.nano"

  network_interface {
    network_interface_id = each.value.id
    device_index         = 0
  }

  tags = {
    Name = "${module.vpc_name.name}-private-fck-nat-${aws_subnet.public[each.key].availability_zone}"
  }
}

resource "aws_route_table" "private_fck_nat" {
  for_each = var.enable_fck_nat ? aws_instance.private_fck_nat : {}

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.private_fck_nat[each.key].id
  }

  tags = {
    Name = "${module.vpc_name.name}-private-fck-nat-${aws_subnet.public[each.key].availability_zone}"
  }
}

resource "aws_route_table_association" "private_fck_nat" {
  for_each = var.enable_fck_nat ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_fck_nat[local.availability_zone_to_public_subnets_map[each.value.availability_zone]].id
}

# NAT Gateway resources - can be enabled/disabled with var.enable_nat_gateways
resource "aws_eip" "private_nat_gateway" {
  for_each = var.enable_nat_gateways ? aws_subnet.public : {}

  domain = "vpc"

  tags = {
    Name = "${module.vpc_name.name}-nat-eip-${each.value.availability_zone}"
  }

  depends_on = [aws_internet_gateway.vpc]
}

resource "aws_nat_gateway" "private_nat_gateway" {
  for_each = var.enable_nat_gateways ? aws_subnet.public : {}

  allocation_id = aws_eip.private_nat_gateway[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${module.vpc_name.name}-nat-${each.value.availability_zone}"
  }

  depends_on = [aws_internet_gateway.vpc]
}

resource "aws_route_table" "private_nat_gateway" {
  for_each = var.enable_nat_gateways ? aws_nat_gateway.private_nat_gateway : {}

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "${module.vpc_name.name}-private-nat-${aws_subnet.public[each.key].availability_zone}"
  }
}

resource "aws_route_table_association" "private_nat_gateway" {
  for_each = var.enable_nat_gateways ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_nat_gateway[local.availability_zone_to_public_subnets_map[each.value.availability_zone]].id
}

# ECR VPC Endpoints
resource "aws_security_group" "ecr_vpc_endpoints" {
  count = var.enable_ecr_vpc_endpoints ? 1 : 0

  name   = "${module.vpc_name.name}-ecr-endpoints"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.enable_ecr_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoints[0].id]

  tags = {
    "Name" = "${module.vpc_name.name}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  count = var.enable_ecr_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.ecr_vpc_endpoints[0].id]

  tags = {
    Name = "${module.vpc_name.name}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_ecr_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_default_route_table.vpc.id]

  tags = {
    Name = "${module.vpc_name.name}-s3"
  }
}
