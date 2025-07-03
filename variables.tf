variable "environment" {
  type = string
}
variable "region_backend" {
  type = string
}

########################################################################
# VPC
########################################################################

variable "vpc_name" {
  description = "The name of the project."
  type        = string

}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "region" {
  description = "The AWS region in which the VPC will be created."
  type        = string
}


variable "single_nat_gateway" {
  description = "Whether to create a single NAT Gateway in the first public subnet."
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for each private subnet."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Whether instances with public IP addresses should get corresponding DNS hostnames."
  type        = bool
}

variable "enable_dns_support" {
  description = "Whether the VPC should have DNS support."
  type        = bool
}

variable "vpc_tags" {
  type = map(string)
}

variable "vpc_flowlog_bucket" {
  type    = string
  default = "toucan-uat-vpc-flowlog-bucket"
}



########################################################################
# PRITUNL
########################################################################
variable "ec2_pritunl_ami_id" {
  type = string
}
variable "ec2_pritunl_instance_type" {
  type = string
}
variable "ec2_pritunl_name" {
  type = string
}
# variable "ec2_pritunl_iam_role_name" {
#   type = string
# }
variable "ec2_pritunl_iam_role_policies" {
  type    = map(string)
  default = {}
}
variable "ec2_pritunl_volume_type" {
  type = string
}
variable "ec2_pritunl_volume_size" {
  type = string
}
# variable "ec2_pritunl_kms_key_id" {
#   type = string
# }
variable "ec2_pritunl_root_encrypted" {
  type = bool
}
variable "ec2_pritunl_ebs_block_devices" {
  type    = list(any)
  default = []
}
variable "ec2_pritunl_tags" {
  type = map(string)
}
variable "ec2_pritunl_key_name" {
  type = string
}
variable "ec2_pritunl_termination_protection" {
  type = bool
}
variable "ec2_pritunl_iam_instance_profile" {
  type = string
}
variable "ec2_pritunl_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ec2_pritunl_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "bucketTags" {
  type = map(string)
}
variable "cred_bucketName" {
  type = string
}

#######################################################################
# KMS
#######################################################################

variable "kms_tags" {
  type = map(string)
}
variable "key_user_list" {
  type = list(string)
}

variable "key_administrators_list" {
  type = list(string)
}
variable "enable_multi_region" {
  type = bool
}

variable "enable_key_rotation" {
  type = bool
}

variable "enable_key" {
  type = bool
}

variable "key_aliases" {
  type = list(string)
}

variable "key_description" {
  type = string
}

variable "key_deletion_window_in_days" {
  type = number
}

variable "key_usage" {
  type = string
}
variable "kms_region" {
  type = string
}

######################################
# Elastic Contianer Registry
######################################
# variable "ecr_tags" {
#   type = map(string)
# }

# variable "repository_names" {
#   type = list(string)
# }

######################################
# ACM
######################################
# variable "main_domain_name" {
#   type = string
# }

# variable "create_route53_records" {
#   type = bool
# }

# variable "validation_method" {
#   type = string
# }

# variable "acm_main_tags" {
#   type = map(string)
# }

#######################################################################
# variable "zone_tags" {
#   type = map(string)
# }
#######################################################################
########################################################################
# ECS
########################################################################
variable "ecs_cluster_name" {
  type = string
}

variable "ecs_cluster_settings" {
  type = any
}
variable "ecs_cluster_tags" {
  type = map(string)
}
variable "ecs_node_kp_name" {
  type = string
}
# variable "ecs_service_name" {
#   type = string
# }
# variable "ecs_container_name" {
#   type = string
# }
# variable "ecs_container_port" {
#   type = string
# }
# variable "ecs_service_tags" {
#   type = map(string)
# }

########################################################################
# ASG
########################################################################
variable "asg_name" {
  type = string
}
variable "asg_tags" {
  type = map(string)
}
variable "asg_security_group_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "asg_security_group_egress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

######################################
# Elastic Contianer Registry
######################################
variable "ecr_tags" {
  type = map(string)
}

variable "repository_names" {
  type = list(string)
}

#####################################
# IAM
#####################################

variable "create_iam_policy" {
  type = bool
}

variable "iam_policy_description" {
  type = string
}

variable "iam_policy_name" {
  type = string
}

variable "iam_policy" {
  type = any
}

variable "iam_policy_tags" {
  type = map(string)
}
########################################################################
# ocapp
########################################################################
variable "ec2_ocapp_ami_id" {
  type = string
}
variable "ec2_ocapp_instance_type" {
  type = string
}
variable "ec2_ocapp_name" {
  type = string
}
# variable "ec2_ocapp_iam_role_name" {
#   type = string
# }
variable "ec2_ocapp_iam_role_policies" {
  type    = map(string)
  default = {}
}
variable "ec2_ocapp_volume_type" {
  type = string
}
variable "ec2_ocapp_volume_size" {
  type = string
}
# variable "ec2_ocapp_kms_key_id" {
#   type = string
# }
variable "ec2_ocapp_root_encrypted" {
  type = bool
}
variable "ec2_ocapp_ebs_block_devices" {
  type    = list(any)
  default = []
}
variable "ec2_ocapp_tags" {
  type = map(string)
}
variable "ec2_ocapp_key_name" {
  type = string
}
variable "ec2_ocapp_termination_protection" {
  type = bool
}
variable "ec2_ocapp_iam_instance_profile" {
  type = string
}
variable "ec2_ocapp_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ec2_ocapp_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
########################################################################
# ocdb
########################################################################
variable "ec2_ocdb_ami_id" {
  type = string
}
variable "ec2_ocdb_instance_type" {
  type = string
}
variable "ec2_ocdb_name" {
  type = string
}
# variable "ec2_ocdb_iam_role_name" {
#   type = string
# }
variable "ec2_ocdb_iam_role_policies" {
  type    = map(string)
  default = {}
}
variable "ec2_ocdb_volume_type" {
  type = string
}
variable "ec2_ocdb_volume_size" {
  type = string
}
# variable "ec2_ocdb_kms_key_id" {
#   type = string
# }
variable "ec2_ocdb_root_encrypted" {
  type = bool
}
variable "ec2_ocdb_ebs_block_devices" {
  type    = list(any)
  default = []
}
variable "ec2_ocdb_tags" {
  type = map(string)
}
variable "ec2_ocdb_key_name" {
  type = string
}
variable "ec2_ocdb_termination_protection" {
  type = bool
}
variable "ec2_ocdb_iam_instance_profile" {
  type = string
}
variable "ec2_ocdb_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ec2_ocdb_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
########################################################################
# API GW
########################################################################
variable "apigw_vpc_link_ingress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "apigw_vpc_link_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

