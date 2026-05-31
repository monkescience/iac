resource "aws_route53_zone" "domain" {
  name = "${var.environment}.${var.region}.monke.science"
  vpc {
    vpc_id = var.vpc_id
  }
}
