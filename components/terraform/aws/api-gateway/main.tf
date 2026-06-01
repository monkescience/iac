data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "private_domain" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "private-domain/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "cognito/terraform.tfstate"
    region = var.region
  }
}

# The ACM certificate for the wildcard domain is managed outside this repo; look it up
# by domain so a rebuild resolves the current ARN instead of a hardcoded one.
data "aws_acm_certificate" "api" {
  domain      = "*.${var.environment}.${var.region}.monke.science"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_lb" "k8s_api_gateway" {
  tags = {
    "elbv2.k8s.aws/cluster" = "monke-eu-central-1-dev-main",
    "ingress.k8s.aws/stack" = "api-gateway"
  }
}

data "aws_lb_listener" "k8s_api_gateway_listener" {
  load_balancer_arn = data.aws_lb.k8s_api_gateway.arn
  port              = 80
}

module "api-gateway" {
  source = "../../../../modules/aws/api-gateway"

  region                      = var.region
  environment                 = var.environment
  project                     = var.project
  eks_subnet_ids              = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  vpc_cidr_blocks             = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
  load_balancer_arn           = data.aws_lb_listener.k8s_api_gateway_listener.arn
  acm_cert_arn                = data.aws_acm_certificate.api.arn
  route53_zone_id             = data.terraform_remote_state.private_domain.outputs.route53_zone_id
  cognito_user_pool_endpoint  = data.terraform_remote_state.cognito.outputs.cognito_user_pool_endpoint
  cognito_user_pool_client_id = data.terraform_remote_state.cognito.outputs.cognito_user_pool_client_id
}
