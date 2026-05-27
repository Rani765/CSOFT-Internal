output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb-acl-main.id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb-acl-main.arn
}

output "web_acl_name" {
  description = "The name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.alb-acl-main.name
}

output "waf_logging_bucket" {
  description = "The S3 bucket used for WAF logging"
  value       = module.alb_waf_logging.s3_bucket_id
}

output "waf_logging_configuration_id" {
  description = "The ID of the WAF logging configuration"
  value       = aws_wafv2_web_acl_logging_configuration.this.id
}
