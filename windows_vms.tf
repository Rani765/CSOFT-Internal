# ####################################################################
# # ocapp
# ####################################################################


module "ocapp-securtiy-group" {
  source      = "./modules/sg"
  name        = "${upper(local.ec2_ocapp_name)}-SG"
  description = "${upper(local.ec2_ocapp_name)} Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = local.ec2_ocapp_ingress_rules
  egress_rules  = local.ec2_ocapp_egress_rules
}

module "ec2_ocapp" {
  source     = "./modules/ec2"
  depends_on = [module.ocapp-securtiy-group, aws_s3_bucket.credential-bucket]
  create     = true
  name       = local.ec2_ocapp_name

  ami                         = local.ec2_ocapp_ami_id
  instance_type               = local.ec2_ocapp_instance_type
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.ocapp-securtiy-group.security_group_id]
  key_name                    = module.keypair_ocapp.key_pair_name
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = local.ec2_ocapp_disable_api_termination
  ebs_optimized               = true
  source_dest_check           = false

  create_iam_instance_profile = false
  iam_instance_profile        = aws_iam_instance_profile.cwm_managed_instance_profile.name


  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = local.ec2_ocapp_root_encrypted
      kms_key_id  = local.ec2_ocapp_kms_key_id
      volume_type = local.ec2_ocapp_volume_type
      volume_size = local.ec2_ocapp_volume_size
      tags = {
        Name = "${local.ec2_ocapp_name}-OS"
      }
    }
  ]

  user_data = <<-EOF
    <powershell>
    Start-Service AmazonSSMAgent
    </powershell>
  EOF 

  tags = local.ec2_ocapp_tags
}

# ####################################################################
# # ocdb
# ####################################################################


module "ocdb-securtiy-group" {
  source      = "./modules/sg"
  name        = "${upper(local.ec2_ocdb_name)}-SG"
  description = "${upper(local.ec2_ocdb_name)} Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = local.ec2_ocdb_ingress_rules
  egress_rules  = local.ec2_ocdb_egress_rules
}

module "ec2_ocdb" {
  source     = "./modules/ec2"
  depends_on = [module.ocdb-securtiy-group, aws_s3_bucket.credential-bucket]
  create     = true
  name       = local.ec2_ocdb_name

  ami                         = local.ec2_ocdb_ami_id
  instance_type               = local.ec2_ocdb_instance_type
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.ocdb-securtiy-group.security_group_id]
  key_name                    = module.keypair_ocdb.key_pair_name
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = local.ec2_ocdb_disable_api_termination
  ebs_optimized               = true
  source_dest_check           = false

  create_iam_instance_profile = false
  iam_instance_profile        = aws_iam_instance_profile.cwm_managed_instance_profile.name


  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = local.ec2_ocdb_root_encrypted
      kms_key_id  = local.ec2_ocdb_kms_key_id
      volume_type = local.ec2_ocdb_volume_type
      volume_size = local.ec2_ocdb_volume_size
      tags = {
        Name = "${local.ec2_ocdb_name}-OS"
      }
    }
  ]

  user_data = <<-EOF
    <powershell>
    Start-Service AmazonSSMAgent
    </powershell>
  EOF 
  tags      = local.ec2_ocdb_tags
}


