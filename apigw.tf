locals {
  alb_listener_arn = "arn:aws:elasticloadbalancing:ap-south-1:024848447708:listener/app/Csoft-prod-alb/5fc1dd795c5839cb/b81bf5f7f5678f06"
}
module "apigw-vpc-link-securtiy-group" {
  source      = "./modules/sg"
  name        = "csoft-prod-apigw-vpc-link-sg"
  description = "apigw vpc link Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = local.apigw_vpc_link_ingress_rules
  egress_rules  = local.apigw_vpc_link_egress_rules
}
resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "csoft-prod-http-vpclink"
  security_group_ids = [module.apigw-vpc-link-securtiy-group.security_group_id]
  subnet_ids         = module.vpc.private_subnets

}
resource "aws_apigatewayv2_api" "this" {
  depends_on = [aws_apigatewayv2_vpc_link.this]

  name                         = "csoft-prod-wiapi-gt"
  protocol_type                = "HTTP"
  description                  = "Csoft prod api gw for wi-api"
  disable_execute_api_endpoint = false
  ip_address_type              = "ipv4"
  body = templatefile("apigw_oas30.yaml", {
    apigw_vpc_link_id = aws_apigatewayv2_vpc_link.this.id
    alb_listener_arn  = local.alb_listener_arn
  })
}
