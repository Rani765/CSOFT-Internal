####################################################################
# Zookeeper - 3 Node Cluster
# OS: Ubuntu | vCPUs: 2 | RAM: 4GB | SSD: 20GB | Type: t3a.medium
####################################################################

locals {
  zk_instance_count = 3
  zk_name           = "CSoft-${local.environment}-Zookeeper"
  zk_instance_type  = "t3a.medium"
  zk_volume_size    = 20
  zk_volume_type    = "gp3"
  zk_tags = {
    Environment = local.environment
    Application = "Zookeeper"
    Cluster     = "zk-cluster"
  }
}

####################################################################
# Zookeeper AMI (Ubuntu)
####################################################################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

####################################################################
# Zookeeper Security Group
####################################################################

module "zookeeper-security-group" {
  source      = "./modules/sg"
  name        = "${local.zk_name}-SG"
  description = "Zookeeper cluster security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Zookeeper client port"
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = ["10.189.0.0/16"]
    },
    {
      description = "Zookeeper follower port"
      from_port   = 2888
      to_port     = 2888
      protocol    = "tcp"
      cidr_blocks = ["10.189.0.0/16"]
    },
    {
      description = "Zookeeper election port"
      from_port   = 3888
      to_port     = 3888
      protocol    = "tcp"
      cidr_blocks = ["10.189.0.0/16"]
    },
    {
      description = "SSH from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    },
    {
      description = "NFS for EFS"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

####################################################################
# Zookeeper Key Pair
####################################################################

module "keypair_zookeeper" {
  source = "./modules/key-pair"

  key_name           = "Csoft-Zookeeper-keypair"
  create_private_key = true

  tags = {
    Name        = "Csoft-Zookeeper-keypair"
    Environment = local.environment
  }
}

####################################################################
# Zookeeper EC2 Instances (3 Nodes)
####################################################################

module "ec2_zookeeper" {
  source   = "./modules/ec2"
  count    = local.zk_instance_count
  create   = true
  name     = "${local.zk_name}-${count.index + 1}"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.zk_instance_type
  availability_zone           = element(module.vpc.azs, count.index)
  subnet_id                   = element(module.vpc.private_subnets, count.index)
  vpc_security_group_ids      = [module.zookeeper-security-group.security_group_id]
  key_name                    = module.keypair_zookeeper.key_pair_name
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  ebs_optimized               = true

  create_iam_instance_profile = false
  iam_instance_profile        = aws_iam_instance_profile.cwm_managed_instance_profile.name

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      kms_key_id  = module.kms_complete.key_arn
      volume_type = local.zk_volume_type
      volume_size = local.zk_volume_size
      tags = {
        Name = "${local.zk_name}-${count.index + 1}-OS"
      }
    }
  ]

  user_data = base64encode(templatefile("${path.module}/scripts/zookeeper-setup.sh", {
    ZK_ID         = count.index + 1
    ZK_NODES      = local.zk_instance_count
    EFS_ID        = aws_efs_file_system.zookeeper.id
    AWS_REGION    = data.aws_region.current.name
  }))

  tags = merge(local.zk_tags, {
    Name   = "${local.zk_name}-${count.index + 1}"
    ZK_ID  = count.index + 1
  })

  depends_on = [module.zookeeper-security-group, aws_efs_file_system.zookeeper]
}

####################################################################
# EFS for Zookeeper (Shared Storage)
####################################################################

resource "aws_efs_file_system" "zookeeper" {
  creation_token = "csoft-prod-zookeeper-efs"
  encrypted      = true
  kms_key_id     = module.kms_complete.key_arn

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(local.zk_tags, {
    Name = "CSoft-Prod-Zookeeper-EFS"
  })
}

####################################################################
# EFS Security Group
####################################################################

module "efs-security-group" {
  source      = "./modules/sg"
  name        = "CSoft-Prod-Zookeeper-EFS-SG"
  description = "Security group for Zookeeper EFS mount targets"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "NFS from VPC"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

####################################################################
# EFS Mount Targets (one per private subnet)
####################################################################

resource "aws_efs_mount_target" "zookeeper" {
  count = length(module.vpc.private_subnets)

  file_system_id  = aws_efs_file_system.zookeeper.id
  subnet_id       = element(module.vpc.private_subnets, count.index)
  security_groups = [module.efs-security-group.security_group_id]
}
