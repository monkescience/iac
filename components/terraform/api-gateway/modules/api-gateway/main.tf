resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${module.this.name}-eks-api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "api_gateway" {
  name               = "${module.this.name}-vpc-link"
  subnet_ids         = var.eks_subnet_ids
  security_group_ids = [aws_security_group.api_gateway.id]
}

resource "aws_security_group" "api_gateway" {
  name        = "${module.this.name}-vpc-link-sg"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from API Gateway"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_blocks
  }

  ingress {
    description = "Allow HTTPS from API Gateway"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${module.this.name}-vpc-link-sg"
  }
}

resource "aws_apigatewayv2_integration" "api_gateway" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = var.load_balancer_arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.api_gateway.id
}

resource "aws_apigatewayv2_domain_name" "api_gateway" {
  domain_name = "*.${var.environment}.${var.region}.monke.science"

  domain_name_configuration {
    certificate_arn = var.acm_cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_stage" "api_gateway" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "${var.region}-${var.environment}"
  auto_deploy = true
}

resource "aws_apigatewayv2_api_mapping" "api_gateway" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  domain_name = aws_apigatewayv2_domain_name.api_gateway.domain_name
  stage       = aws_apigatewayv2_stage.api_gateway.name
}

resource "aws_route53_record" "api_gateway" {
  zone_id = var.route53_zone_id
  name    = "*.${var.environment}.${var.region}.monke.science"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api_gateway.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_apigatewayv2_route" "api_gateway" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  route_key          = "ANY /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.api_gateway.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.api_gateway.id
  authorization_type = "JWT"
}

# # Authorizer for Cognito
resource "aws_apigatewayv2_authorizer" "api_gateway" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://${var.cognito_user_pool_endpoint}"
  }
}
