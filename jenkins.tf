####################################################################
# Jenkins Server
# OS: Ubuntu 24.04 | Type: t3a.large | Volume: 30GB
####################################################################

locals {
  jenkins_name          = "CSoft-${local.environment}-Jenkins"
  jenkins_instance_type = "t3a.large"
  jenkins_volume_size   = 30
  jenkins_tags = {
    Environment = local.environment
    Application = "Jenkins"
  }
}

####################################################################
# Jenkins Security Group
####################################################################

module "jenkins-security-group" {
  source      = "./modules/sg"
  name        = "${local.jenkins_name}-SG"
  description = "Jenkins server security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Jenkins Web UI"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    },
    {
      description = "SSH from VPC"
      from_port   = 22
      to_port     = 22
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
# Jenkins Key Pair
####################################################################

module "keypair_jenkins" {
  source = "./modules/key-pair"

  key_name           = "Csoft-Jenkins-keypair"
  create_private_key = true

  tags = {
    Name        = "Csoft-Jenkins-keypair"
    Environment = local.environment
  }
}

####################################################################
# Jenkins EC2 Instance
####################################################################

module "ec2_jenkins" {
  source     = "./modules/ec2"
  depends_on = [module.jenkins-security-group]
  create     = true
  name       = local.jenkins_name

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.jenkins_instance_type
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids      = [module.jenkins-security-group.security_group_id]
  key_name                    = module.keypair_jenkins.key_pair_name
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
      volume_type = "gp3"
      volume_size = local.jenkins_volume_size
      tags = {
        Name = "${local.jenkins_name}-OS"
      }
    }
  ]

  user_data = file("${path.module}/scripts/jenkins-setup.sh")

  tags = local.jenkins_tags
}

####################################################################
# Store Jenkins Key in S3
####################################################################

resource "aws_s3_object" "keypair_jenkins_pem" {
  bucket  = aws_s3_bucket.credential-bucket.bucket
  key     = "keypairs/Csoft-Jenkins-keypair.pem"
  content = module.keypair_jenkins.private_key_pem

  tags = {
    Name = "Csoft-Jenkins-keypair"
  }
}
