data "aws_iam_policy_document" "log-delivery" {
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${local.s3_env_bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::${local.s3_env_bucket}"]
  }
}

 module "s3_env_bucket" {
   source = "./modules/s3"
   bucket = local.s3_env_bucket
   attach_policy = true
   policy        = data.aws_iam_policy_document.log-delivery.json
   lifecycle_rule = [
     {
       id      = "5yearexpiration"
       enabled = true
       expiration = {
         days = 1825
         #expired_object_delete_marker = true
       }
       # noncurrent_version_expiration = {
      #   days = 1825
       # }
     }
   ]
#   force_destroy = true
 }