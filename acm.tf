# locals {
#   main_domain_name       = var.main_domain_name
#   create_route53_records = var.create_route53_records
#   validation_method      = var.validation_method
#   acm_main_tags          = merge(var.acm_main_tags, { Name = local.main_domain_name })
#   acm_zone_id            = "Z08321731XS1LUVSSIDLM"
# }
# module "acm_main" {
#   source = "./modules/acm"

#   create_certificate = true

#   zone_id = local.acm_zone_id

#   domain_name               = local.main_domain_name
#   subject_alternative_names = ["*.${local.main_domain_name}"]
#   create_route53_records    = local.create_route53_records
#   validation_method         = local.validation_method

#   validate_certificate = true

#   tags = local.acm_main_tags
# }

# # module "acm_nv" {
# #   source = "./modules/acm"

# #   create_certificate = true

# #   domain_name               = local.main_domain_name
# #   subject_alternative_names = ["*.${local.main_domain_name}"]
# #   create_route53_records    = false #local.create_route53_records
# #   validation_method         = local.validation_method

# #   validate_certificate = false

# #   tags = local.acm_main_tags

# #   providers = {
# #     aws = aws.virginia
# #   }
# # }