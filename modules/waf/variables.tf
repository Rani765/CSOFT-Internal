variable "waf_name" {
  description = "Name of the WAF Web ACL"
  type        = string
}

variable "waf_description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "WAF Web ACL for ALB protection"
}

variable "alb_waf_s3" {
  description = "S3 bucket name for WAF logs"
  type        = string
}

variable "alb_arns" {
  description = "Map of ALB identifiers to their ARNs for WAF association"
  type        = map(string)
  default     = {}
}

variable "web_acl_tags" {
  description = "Tags for the WAF Web ACL"
  type        = map(string)
  default     = {}
}
