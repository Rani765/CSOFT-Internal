####################################################################
# ACM Certificate - holaamigoes.in
####################################################################

locals {
  main_domain_name = "holaamigoes.in"
  acm_zone_id      = module.route53_public_zone.route53_zone_zone_id["holaamigoes.in"]
  acm_main_tags = {
    Environment = local.environment
    Name        = "holaamigoes.in"
  }
}

module "acm_main" {
  source = "./modules/acm"

  create_certificate = true

  zone_id = local.acm_zone_id

  domain_name               = "*.${local.main_domain_name}"
  subject_alternative_names = [local.main_domain_name]
  create_route53_records    = true
  validation_method         = "DNS"

  validate_certificate = true

  tags = local.acm_main_tags
}
