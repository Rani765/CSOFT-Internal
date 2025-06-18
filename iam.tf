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