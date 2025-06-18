# module "s3_env_bucket" {
#   source = "./modules/s3"
#   bucket = local.s3_env_bucket
#   #attach_policy = true
#   #policy        = data.aws_iam_policy_document.log-delivery.json
# #   lifecycle_rule = [
# #     {
# #       id      = "5yearexpiration"
# #       enabled = true
# #       expiration = {
# #         days = 1825
# #         #expired_object_delete_marker = true
# #       }
# #       # noncurrent_version_expiration = {
# #       #   days = 1825
# #       # }
# #     }
# #   ]
#   force_destroy = true
# }