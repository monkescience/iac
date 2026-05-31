resource "aws_security_group" "vpn" {
  name        = "${module.this.name}-sg"
  description = "Security group for the OpenVPN server"
  vpc_id      = var.vpc_id

  ingress {
    description = "OpenVPN"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = module.this.name
  }
}

data "aws_ami" "image" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-*-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_instance" "vpn" {
  ami           = data.aws_ami.image.id
  instance_type = "t4g.nano"

  subnet_id                   = var.vpc_public_subnet
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.vpn.name

  user_data_base64 = base64encode(file("${path.module}/cloud-init.yaml"))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = module.this.name
  }
}
