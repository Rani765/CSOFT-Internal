data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
####################################################################
# PRITUNL
####################################################################
data "aws_iam_policy_document" "flow_log_s3" {
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${local.vpc_flowlog_bucket}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::${local.vpc_flowlog_bucket}"]
  }
}
####################################################################
# PRITUNL
####################################################################
data "aws_key_pair" "pritunl" {
  key_name           = var.ec2_pritunl_key_name
  include_public_key = true
}
data "aws_key_pair" "ocapp" {
  key_name           = var.ec2_ocapp_key_name
  include_public_key = true
}
data "aws_key_pair" "ocdb" {
  key_name           = var.ec2_ocdb_key_name
  include_public_key = true
}