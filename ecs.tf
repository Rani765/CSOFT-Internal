resource "aws_ecs_account_setting_default" "defaults" {
  for_each = local.ecs_account_setting_default

  name  = each.key
  value = each.value
}

module "ecs_cluster" {
  source                    = "./modules/ecs_module/cluster"
  create                    = true
  cluster_name              = local.ecs_cluster_name
  cluster_settings          = local.ecs_cluster_settings
  create_task_exec_iam_role = true
  create_task_exec_policy   = true
  # task_exec_iam_role_policies = {
  #   additonal_policy_arn = "arn:aws:iam::766497522778:policy/RevUpAI-POC-cluster-additional"
  # } #policies arns
  # Capacity provider - autoscaling groups
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    # On-demand instances
    backend-ng = {
      auto_scaling_group_arn         = module.autoscaling["backend-ng"].autoscaling_group_arn
      managed_termination_protection = "DISABLED"
      managed_draining               = "DISABLED"
      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "DISABLED"
        target_capacity           = 75
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}
locals {
  asg_name                         = var.asg_name
  asg_security_group_ingress_rules = var.asg_security_group_ingress_rules
  asg_security_group_egress_rules  = var.asg_security_group_egress_rules
  asg_tags                         = var.asg_tags

}
module "asg_security_group" {
  source      = "./modules/sg"
  name        = "${title(local.asg_name)}-SG"
  description = "${title(local.asg_name)} Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = local.asg_security_group_ingress_rules
  egress_rules  = local.asg_security_group_egress_rules

}

module "autoscaling" {
  source                 = "./modules/autoscaling_module"
  create                 = true
  create_launch_template = true
  depends_on             = [module.asg_security_group]
  for_each = {
    # On-demand instances
    backend-ng = {
      instance_type              = "t3a.medium"
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_type = "gp3"
            volume_size = "30"
            iops        = "3000"
            throughput  = "125"
            encrypted   = true
            kms_key_id  = module.kms_complete.key_arn
          }
        }
      ]
      user_data = <<-EOT
        #!/bin/bash
        sudo sync; sudo echo 1 > /proc/sys/vm/drop_caches
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${local.ecs_cluster_name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(local.ecs_cluster_tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
        (sudo crontab -l; echo "*/1 * * * * /bin/bash -c 'sync; echo 1 > /proc/sys/vm/drop_caches' >> /var/log/clear_cache.log 2>&1") | sudo crontab - 
      EOT
    }
  }

  name = "${local.asg_name}-${each.key}"

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = each.value.instance_type

  security_groups                 = [module.asg_security_group.security_group_id]
  user_data                       = base64encode(each.value.user_data)
  block_device_mappings           = each.value.block_device_mappings
  ebs_optimized                   = true
  ignore_desired_capacity_changes = false
  key_name                        = local.ecs_node_kp_name

  create_iam_instance_profile = true
  iam_role_name               = "CSoft-Prod-ECS-Node-Role"
  #iam_instance_profile_name   = "CWM-ECS-EC2-Role-InstanceProfile"
  iam_role_description = "ECS role for ${local.asg_name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    additional                          = aws_iam_policy.node_additional.arn
  }

  vpc_zone_identifier = [module.vpc.private_subnets[1]]
  health_check_type   = "EC2"
  min_size            = 0
  max_size            = 4
  desired_capacity    = 1

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = false


  tags = local.asg_tags
}


resource "aws_iam_policy" "node_additional" {
  name        = "${local.ecs_cluster_name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : [
              "ap-south-1",
              "us-east-1"
            ]
          }
        },
        "Action" : [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:Describe*",
          "cloudwatch:ListMetrics",
          "autoscaling:Describe*",
          "ec2:Describe*",
          "ec2messages:DeleteMessage",
          "ec2messages:GetEndpoint",
          "ssm:PutInventory",
          "ec2messages:FailMessage",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:SendReply",
          "ec2messages:GetMessages",
          "elasticloadbalancing:Describe*",
          "kms:Get*",
          "kms:List*",
          "kms:Describe*",
          "kms:Decrypt",
          "kms:Encrypt",
          "ssm-guiconnect:*",
          "kms:Sign",
          "logs:Create*",
          "logs:Describe*",
          "logs:PutLogEvents",
          "ssm:Describe*",
          "ssm:List*",
          "ssm:Get*",
          "s3:PutObject",
          "s3:GetObject",
          "s3:List*",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:CreateControlChannel",
          "ssm:UpdateInstanceInformation"
        ],
        "Resource" : "*",
        "Effect" : "Allow",
        "Sid" : "AllowOnlyCWSSM"
      }
    ]
  })

  tags = local.ecs_cluster_tags
}