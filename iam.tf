locals {
  create_iam_policy      = var.create_iam_policy
  iam_policy_description = var.iam_policy_description
  iam_policy_name        = var.iam_policy_name
  iam_policy_tags        = var.iam_policy_tags
}
module "iam_policy" {
  source        = "./modules/iam_module/iam-policy"
  create_policy = local.create_iam_policy
  description   = local.iam_policy_description
  name          = local.iam_policy_name
  policy        = jsonencode(var.iam_policy)
  tags          = local.iam_policy_tags
}

####################################################################
# IAM Role & Instance Profile for EC2 (SSM Managed)
####################################################################

resource "aws_iam_role" "cwm_managed_instance_role" {
  name = "CWMManagedInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = local.environment
    Name        = "CWMManagedInstanceRole"
  }
}

resource "aws_iam_role_policy_attachment" "cwm_ssm_core" {
  role       = aws_iam_role.cwm_managed_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cwm_cloudwatch" {
  role       = aws_iam_role.cwm_managed_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cwm_s3_read" {
  role       = aws_iam_role.cwm_managed_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "cwm_managed_instance_profile" {
  name = "CWMManagedInstanceRole"
  role = aws_iam_role.cwm_managed_instance_role.name
}

####################################################################
# ECS Task Execution Role
####################################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "Csoft-Task-Execution-Role"

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid       = ""
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = local.environment
    Name        = "Csoft-Task-Execution-Role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
