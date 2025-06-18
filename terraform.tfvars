region_backend = "ap-south-1"
########################################
# VPC
########################################
environment          = "prod"
vpc_cidr             = "10.189.0.0/16"
region               = "ap-south-1"
vpc_name             = "csoft"
single_nat_gateway   = "true"
enable_nat_gateway   = "true"
enable_dns_hostnames = "true"
enable_dns_support   = "true"
vpc_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft"
  "Layer"         = "Gateway"
}
vpc_flowlog_bucket = "csoft-prod-vpcflowlog"

########################################
# Pritunl
########################################
cred_bucketName = "csoft-prod-credentials"
bucketTags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft",
  "Layer"         = "Storage"
}
ec2_pritunl_ami_id        = "ami-0b09627181c8d5778"
ec2_pritunl_instance_type = "t3a.micro"
ec2_pritunl_name          = "PRITUNL"
#ec2_pritunl_iam_role_name = "CWMManagedInstanceRole"
ec2_pritunl_volume_type = "gp3"
ec2_pritunl_volume_size = "20"
#ec2_pritunl_kms_key_id     = ""
ec2_pritunl_root_encrypted = true
ec2_pritunl_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft",
  "Layer"         = "Gateway"
}
ec2_pritunl_key_name               = "Csoft-Pritunl-VPN-1b-keypair"
ec2_pritunl_termination_protection = true
ec2_pritunl_iam_instance_profile   = "CWMManagedInstanceRole"
ec2_pritunl_ingress_rules = [
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  },
  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 1557
    protocol    = "udp"
    to_port     = 1557
  },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 2223
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 2223
    protocol    = "tcp"
    to_port     = 2223
  },

]
ec2_pritunl_egress_rules = [{
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
}]
########################################################################
# KMS
########################################################################
kms_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft",
  "Layer"         = "Security"
}
key_administrators_list = [
  "arn:aws:iam::024848447708:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::024848447708:role/Workmates-SSO-L2SupportRole",
  "arn:aws:iam::024848447708:role/Terraform-deployer-role"
]
key_user_list = [
  "arn:aws:iam::024848447708:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::024848447708:role/Workmates-SSO-L2SupportRole",
  "arn:aws:iam::024848447708:role/Terraform-deployer-role",
  "arn:aws:iam::024848447708:role/CWMManagedInstanceRole",
  "arn:aws:iam::024848447708:role/CSoft-Prod-ECS-Node-Role",
  "arn:aws:iam::024848447708:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
]
key_aliases                 = ["CSOFT-PROD-CMK"]
key_description             = "Csoft Prod Customer managed Key"
key_deletion_window_in_days = 7
key_usage                   = "ENCRYPT_DECRYPT"
kms_region                  = "ap-south-1"
enable_multi_region         = false
enable_key_rotation         = false
enable_key                  = true


# ########################################################################
# # ACM
# ########################################################################
# main_domain_name       = "revmigrate.com"
# create_route53_records = "true"
# validation_method      = "DNS"
# acm_main_tags = {
#   "Implementedby" = "Workmates",
#   "Managedby"     = "Csoft",
#   "Environment"   = "Prod",
#   "Project"       = "Csoft",
#   "Layer"         = "SSL"
# }
# ########################################################################
# # R53
# ########################################################################
# zone_tags = {
#   "Implementedby" = "Workmates",
#   "Managedby"     = "Csoft",
#   "Environment"   = "Prod",
#   "Project"       = "Csoft",
#   "Layer"         = "DNS"
# }
########################################################################
# ECS Cluster
########################################################################
ecs_cluster_name = "CSoft"
ecs_node_kp_name = "CSoft-ECS-Node-keypair"

ecs_cluster_settings = [
  {
    name  = "containerInsights"
    value = "disabled"
  }
]

ecs_cluster_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft",
  "Layer"         = "App"
}

########################################################################
# ASG for ECS
########################################################################
asg_name = "CSoft-Prod-Ecs-Ng-Asg"
asg_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft",
  "Layer"         = "App"
}
asg_security_group_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

asg_security_group_ingress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

########################################################################
# ECR
########################################################################

repository_names = [
  "csoft-prod-identity-server",
  "csoft-prod-jobserver",
  "csoft-prod-solr-efs",
  "csoft-prod-tika-server",
  "csoft-prod-wiseindex/wiapi",
  "cosft-prod-zookeeper"
]

ecr_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft",
  "Layer"         = "Storage"
}
###############################
# IAM 
###############################
create_iam_policy      = true
iam_policy_description = "ecs task exec addtional policy"
iam_policy_name        = "csoft-prod-additonal-access-policy"
iam_policy = {
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Sid" : "ecss3envaccess",
      "Effect" : "Allow",
      "Action" : [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource" : [
        "arn:aws:s3:::<>",
        "arn:aws:s3:::<>/*"
      ]
    },
    {
      "Sid" : "s3websiteaccess",
      "Effect" : "Allow",
      "Action" : [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObjectTagging",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource" : [
        "arn:aws:s3:::<>",
        "arn:aws:s3:::<>/*"
      ]
    },
    {
      "Sid" : "cdninvalidation",
      "Effect" : "Allow",
      "Action" : [
        "s3:GetObject",
        "cloudfront:GetDistribution",
        "cloudfront:ListInvalidations",
        "cloudfront:GetInvalidation",
        "cloudfront:CreateInvalidation"
      ],
      "Resource" : [
        "arn:aws:cloudfront::<>:distribution/*"
      ]
    },
    {
      "Sid" : "efsFullAccess",
      "Effect" : "Allow",
      "Action" : "elasticfilesystem:*",
      "Resource" : "*"
    },
    {
      "Sid" : "ecrFullAccess",
      "Effect" : "Allow",
      "Action" : "ecr:*",
      "Resource" : "*"
    }
  ]

}

iam_policy_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Csoft",
  "Environment"   = "Prod",
  "Project"       = "Csoft",
  "Layer"         = "Security"
}