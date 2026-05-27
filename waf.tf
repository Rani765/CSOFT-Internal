####################################################################
# WAF
####################################################################

module "waf" {
  source = "./modules/waf"

  waf_name        = "CSoft-Prod-WAF"
  waf_description = "CSoft Production WAF for ALB protection"
  alb_waf_s3      = "csoft-prod-waf-logs-use1"

  alb_arns = {
    "private-alb" = module.alb.arn
    "public-alb"  = module.alb-pub.arn
  }

  web_acl_tags = {
    Environment = local.environment
    Name        = "CSoft-Prod-WAF"
  }
}
