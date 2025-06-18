# locals {
#   ecr_tags         = var.ecr_tags
#   ecr_kms_key_arn  = module.kms_complete.key_arn
#   repository_names = var.repository_names
# }
# module "ecr_repositories" {
#   source = "./modules/ecr_module"

#   repository_names        = local.repository_names
#   create                  = true
#   create_repository       = true
#   create_lifecycle_policy = true
#   repository_lifecycle_policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1,
#         description  = "Keep lastest 10 images",
#         selection = {
#           tagStatus   = "any",
#           countType   = "imageCountMoreThan",
#           countNumber = 10
#         },
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
#   repository_type                 = "private"
#   repository_image_tag_mutability = "MUTABLE"
#   repository_encryption_type      = "KMS"
#   repository_kms_key              = local.ecr_kms_key_arn
#   repository_force_delete         = true
#   repository_image_scan_on_push   = true
#   tags                            = local.ecr_tags
# }