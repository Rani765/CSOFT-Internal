################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "./modules/VPC"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 1)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 7)]

  # public_subnet_tags = {
  #   "kubernetes.io/role/elb" = 1
  # }

  # private_subnet_tags = {
  #   "kubernetes.io/role/internal-elb" = 1
  # }

  single_nat_gateway = local.single_nat_gateway
  enable_nat_gateway = local.enable_nat_gateway

  enable_dns_hostnames = local.enable_dns_hostnames
  enable_dns_support   = local.enable_dns_support

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.vpc-flowlog-bucket.s3_bucket_arn

  tags = local.vpc_tags
}
module "vpc-flowlog-bucket" {
  source = "./modules/s3"
  bucket = local.vpc_flowlog_bucket
  #attach_policy   = true
  policy        = data.aws_iam_policy_document.flow_log_s3.json
  force_destroy = true
}

# #####################################################
# # VPC Endpoints
# #####################################################
## Route Tables for S3 Gateway
module "vpc_endpoints" {
  source = "./modules/VPC/vpc-endpoints"

  create = true
  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = [module.vpc.private_route_table_ids[0], module.vpc.public_route_table_ids[0]]
      tags            = { Name = "${local.vpc_name}-S3-Endpoint" }
    }
  }

  tags = merge(local.vpc_tags, {
    Endpoint = "true"
  })
}

# ####################################################################
# # PRITUNL
# ####################################################################


module "pritunl-securtiy-group" {
  source      = "./modules/sg"
  name        = "${upper(local.ec2_pritunl_name)}-SG"
  description = "${upper(local.ec2_pritunl_name)} Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = local.ec2_pritunl_ingress_rules
  egress_rules  = local.ec2_pritunl_egress_rules
}

module "ec2_pritunl" {
  source     = "./modules/ec2"
  depends_on = [module.pritunl-securtiy-group, aws_s3_bucket.credential-bucket]
  create     = true
  name       = local.ec2_pritunl_name

  ami                         = local.ec2_pritunl_ami_id
  instance_type               = local.ec2_pritunl_instance_type
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.pritunl-securtiy-group.security_group_id]
  key_name                    = data.aws_key_pair.pritunl.key_name
  associate_public_ip_address = true
  disable_api_stop            = false
  disable_api_termination     = local.ec2_pritunl_disable_api_termination
  ebs_optimized               = true
  source_dest_check           = false

  create_iam_instance_profile = false
  iam_instance_profile        = local.ec2_pritunl_iam_instance_profile


  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = local.ec2_pritunl_root_encrypted
      kms_key_id  = local.ec2_pritunl_kms_key_id
      volume_type = local.ec2_pritunl_volume_type
      volume_size = local.ec2_pritunl_volume_size
      tags = {
        Name = "${local.ec2_pritunl_name}-OS"
      }
    }
  ]
  #   # ebs_block_device = [
  #   #   {
  #   #     device_name = "/dev/sdf"
  #   #     volume_type = "gp3"
  #   #     volume_size = 30
  #   #     encrypted   = true
  #   #     kms_key_id  = local.ec2_pritunl_kms_key_id
  #   #     tags = merge(
  #   #       {
  #   #         Name = "${local.ec2_pritunl_name}-DATA"
  #   #       },
  #   #       local.ec2_pritunl_tags
  #   #     )
  #   #   }
  #   # ]

  user_data = templatefile("./scripts/pritunl-al2023.sh", { S3_BUCKET_NAME = aws_s3_bucket.credential-bucket.bucket })

  tags = local.ec2_pritunl_tags
}

# ################################
# # PRITUNL Supoorting resources
# ################################

resource "aws_eip" "vpn-eip" {
  domain = "vpc"

  instance = module.ec2_pritunl.id
  tags = merge(
    {
      Name = "${local.ec2_pritunl_name}-EIP"
    },
    local.ec2_pritunl_tags
  )
}
resource "aws_s3_bucket" "credential-bucket" {
  bucket        = local.bucketName
  force_destroy = true

  tags = local.bucketTags
}

