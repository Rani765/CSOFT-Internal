################################################################################
# Common Locals
################################################################################
locals {
  environment = var.environment
}

################################################################################
# VPC Module
################################################################################
locals {

  vpc_name = "${var.vpc_name}-${local.environment}"
  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  single_nat_gateway = var.single_nat_gateway
  enable_nat_gateway = var.enable_nat_gateway

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  vpc_tags             = var.vpc_tags
  vpc_flowlog_bucket   = var.vpc_flowlog_bucket
}
####################################################################
# KMS
####################################################################
locals {
  kms_tags                    = var.kms_tags
  region                      = var.kms_region
  key_description             = var.key_description
  key_aliases                 = var.key_aliases
  key_deletion_window_in_days = var.key_deletion_window_in_days
  key_usage                   = var.key_usage
}
####################################################################
# PRITUNL
####################################################################

locals {
  ec2_pritunl_key_name      = var.ec2_pritunl_key_name
  ec2_pritunl_name          = "CSoft-${local.environment}-${var.ec2_pritunl_name}"
  ec2_pritunl_ingress_rules = var.ec2_pritunl_ingress_rules
  ec2_pritunl_egress_rules  = var.ec2_pritunl_egress_rules
  ec2_pritunl_ami_id        = var.ec2_pritunl_ami_id
  ec2_pritunl_instance_type = var.ec2_pritunl_instance_type
  #ec2_pritunl_iam_role_name           = var.ec2_pritunl_iam_role_name
  ec2_pritunl_iam_role_policies       = var.ec2_pritunl_iam_role_policies
  ec2_pritunl_volume_type             = var.ec2_pritunl_volume_type
  ec2_pritunl_volume_size             = var.ec2_pritunl_volume_size
  ec2_pritunl_kms_key_id              = module.kms_complete.key_arn
  ec2_pritunl_root_encrypted          = var.ec2_pritunl_root_encrypted
  ec2_pritunl_ebs_block_devices       = var.ec2_pritunl_ebs_block_devices
  ec2_pritunl_tags                    = var.ec2_pritunl_tags
  ec2_pritunl_disable_api_termination = var.ec2_pritunl_termination_protection
  ec2_pritunl_iam_instance_profile    = var.ec2_pritunl_iam_instance_profile
  bucketName                          = var.cred_bucketName
  bucketTags                          = var.bucketTags

}
####################################################################
# ocapp
####################################################################

locals {
  ec2_ocapp_key_name      = var.ec2_ocapp_key_name
  ec2_ocapp_name          = "CSoft-${local.environment}-${var.ec2_ocapp_name}"
  ec2_ocapp_ingress_rules = var.ec2_ocapp_ingress_rules
  ec2_ocapp_egress_rules  = var.ec2_ocapp_egress_rules
  ec2_ocapp_ami_id        = var.ec2_ocapp_ami_id
  ec2_ocapp_instance_type = var.ec2_ocapp_instance_type
  #ec2_ocapp_iam_role_name           = var.ec2_ocapp_iam_role_name
  ec2_ocapp_iam_role_policies       = var.ec2_ocapp_iam_role_policies
  ec2_ocapp_volume_type             = var.ec2_ocapp_volume_type
  ec2_ocapp_volume_size             = var.ec2_ocapp_volume_size
  ec2_ocapp_kms_key_id              = module.kms_complete.key_arn
  ec2_ocapp_root_encrypted          = var.ec2_ocapp_root_encrypted
  ec2_ocapp_ebs_block_devices       = var.ec2_ocapp_ebs_block_devices
  ec2_ocapp_tags                    = var.ec2_ocapp_tags
  ec2_ocapp_disable_api_termination = var.ec2_ocapp_termination_protection
  ec2_ocapp_iam_instance_profile    = var.ec2_ocapp_iam_instance_profile

}
####################################################################
# ocdb
####################################################################

locals {
  ec2_ocdb_key_name      = var.ec2_ocdb_key_name
  ec2_ocdb_name          = "CSoft-${local.environment}-${var.ec2_ocdb_name}"
  ec2_ocdb_ingress_rules = var.ec2_ocdb_ingress_rules
  ec2_ocdb_egress_rules  = var.ec2_ocdb_egress_rules
  ec2_ocdb_ami_id        = var.ec2_ocdb_ami_id
  ec2_ocdb_instance_type = var.ec2_ocdb_instance_type
  #ec2_ocdb_iam_role_name           = var.ec2_ocdb_iam_role_name
  ec2_ocdb_iam_role_policies       = var.ec2_ocdb_iam_role_policies
  ec2_ocdb_volume_type             = var.ec2_ocdb_volume_type
  ec2_ocdb_volume_size             = var.ec2_ocdb_volume_size
  ec2_ocdb_kms_key_id              = module.kms_complete.key_arn
  ec2_ocdb_root_encrypted          = var.ec2_ocdb_root_encrypted
  ec2_ocdb_ebs_block_devices       = var.ec2_ocdb_ebs_block_devices
  ec2_ocdb_tags                    = var.ec2_ocdb_tags
  ec2_ocdb_disable_api_termination = var.ec2_ocdb_termination_protection
  ec2_ocdb_iam_instance_profile    = var.ec2_ocdb_iam_instance_profile

}
####################################################################
# ECR
####################################################################
# locals {
#   ecr_tags         = var.ecr_tags
#   ecr_kms_key_arn  = module.kms_complete.key_arn
#   repository_names = var.repository_names
# }
####################################################################
# S3
####################################################################
locals {
  s3_env_bucket = "csoft-env-bucket"
}
# ####################################################################
# # ALB
# ####################################################################
locals {
  alb_name     = "Csoft-prod-alb"
  alb_name_pub = "Csoft-prod-pub-alb"
  alb_tags = {

  }
  alb_vpc_id = module.vpc.vpc_id
  alb_global_egress_rules = [{
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }]
  alb_global_ingress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
    }
  ]
}
####################################################################
# ECS
####################################################################
locals {
  ecs_cluster_name     = "${var.ecs_cluster_name}-${local.environment}-cluster"
  ecs_cluster_settings = var.ecs_cluster_settings
  ecs_cluster_tags     = var.ecs_cluster_tags
  ecs_account_setting_default = {
    "awsvpcTrunking" = "enabled"
  }
  ecs_node_kp_name = var.ecs_node_kp_name
}
####################################################################
# API GW
####################################################################
locals {
  apigw_vpc_link_ingress_rules = var.apigw_vpc_link_ingress_rules
  apigw_vpc_link_egress_rules  = var.apigw_vpc_link_egress_rules

}