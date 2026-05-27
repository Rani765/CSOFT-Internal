####################################################################
# WAF - CloudFront (Global Scope)
####################################################################

module "waf" {
  source = "./modules/waf"

  waf_name        = "CSoft-Prod-WAF"
  waf_description = "CSoft Production WAF for CloudFront"
  waf_scope       = "CLOUDFRONT"
  alb_waf_s3      = "csoft-prod-waf-logs-use1"

  alb_arns = {}

  web_acl_tags = {
    Environment = local.environment
    Name        = "CSoft-Prod-WAF"
  }
}
