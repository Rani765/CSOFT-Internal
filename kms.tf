module "kms_complete" {
  source                  = "./modules/kms"
  create                  = true
  is_enabled              = var.enable_key
  deletion_window_in_days = local.key_deletion_window_in_days
  description             = local.key_description
  enable_key_rotation     = var.enable_key_rotation
  key_usage               = local.key_usage
  multi_region            = var.enable_multi_region
  enable_default_policy   = true

  key_owners         = var.key_administrators_list
  key_administrators = var.key_administrators_list
  key_users          = var.key_user_list
  key_service_users  = var.key_user_list

  aliases                 = local.key_aliases
  aliases_use_name_prefix = false
  tags                    = local.kms_tags
}