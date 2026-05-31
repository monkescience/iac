data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

# tflint-ignore: terraform_unused_declarations
data "terraform_remote_state" "ssl_dns" {
  backend = "s3"
  config = {
    bucket = "${var.project}-${var.region}-${var.environment}-iac-tofu-state"
    key    = "ssl-dns/terraform.tfstate"
    region = var.region
  }
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
  acm_cert_arn                = var.acm_cert_arn
  route53_zone_id             = var.route53_zone_id
  cognito_user_pool_endpoint  = var.cognito_user_pool_endpoint
  cognito_user_pool_client_id = var.cognito_user_pool_client_id
}
