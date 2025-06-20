resource "aws_acm_certificate" "monke_science" {
  domain_name       = "*.${var.environment}.${var.region}.monke.science"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  key_algorithm = "EC_prime256v1"
}

resource "aws_route53_zone" "monke_science" {
  name = "${var.environment}.${var.region}.monke.science"
}

resource "aws_route53_record" "monke_science" {
  for_each = {
    for dvo in aws_acm_certificate.monke_science.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.monke_science.zone_id
}

resource "aws_acm_certificate_validation" "monke_science" {
  certificate_arn         = aws_acm_certificate.monke_science.arn
  validation_record_fqdns = [for record in aws_route53_record.monke_science : record.fqdn]
}
