module "frontend_website" {
  source = "./modules/s3"
  bucket = "csoft-wiseindex-app-prod"
  #attach_policy   = true
  #policy        = jsonencode()
  force_destroy = true
}

module "cloudfront_frontend" {
  depends_on = [module.frontend_website]
  source     = "./modules/cloudfront"
  #aliases    = ["wiseindex.app"]
  comment    = "wiseindex.app Frontend prod"
  enabled    = true
  staging    = false

  http_version                    = "http2"
  is_ipv6_enabled                 = true
  price_class                     = "PriceClass_All"
  retain_on_delete                = false
  wait_for_deployment             = false
  continuous_deployment_policy_id = null
  create_monitoring_subscription  = false
  create_origin_access_identity   = false
  create_origin_access_control    = true
  default_root_object             = "index.html"
  #web_acl_id                      = ""
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  origin = {
    s3-website = { # with origin access control settings (recommended)
      domain_name           = module.frontend_website.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac" # key in `origin_access_control`

    }
  }
  default_cache_behavior = {
    target_origin_id       = "s3-website"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    use_forwarded_values = false

    cache_policy_name          = "Managed-CachingOptimized"
    origin_request_policy_name = "Managed-CORS-S3Origin"
    #response_headers_policy_name = ""
    compress = true
  }

  #   ordered_cache_behavior = [
  #     {
  #       path_pattern           = "/*.js"
  #       target_origin_id       = "s3-website"
  #       viewer_protocol_policy = "redirect-to-https"

  #       allowed_methods = ["GET", "HEAD"]
  #       cached_methods  = ["GET", "HEAD"]

  #       use_forwarded_values = false
  #       compress             = false

  #       cache_policy_name            = aws_cloudfront_cache_policy._1year_cache_policy.name
  #       origin_request_policy_name   = "Managed-AllViewer"
  #       response_headers_policy_name = "Managed-SimpleCORS"

  #     }
  #   ]
  custom_error_response = [
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 5
    }
  ]
#   viewer_certificate = {
#     acm_certificate_arn      = module.acm_main.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }
  #     logging_config = {
  #     bucket = ""
  #     prefix = "cloudfront"
  #   }

}
