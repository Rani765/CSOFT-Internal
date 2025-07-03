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
