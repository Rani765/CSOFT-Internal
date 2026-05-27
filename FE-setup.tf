module "frontend_website" {
  source = "./modules/s3"
  bucket = "csoft-wiseindex-app-prod-use1"
  #attach_policy   = true
  #policy        = jsonencode()
  force_destroy = true
}

####################################################################
# Upload index.html to S3
####################################################################

resource "aws_s3_object" "index_html" {
  bucket       = "csoft-wiseindex-app-prod-use1"
  key          = "index.html"
  source       = "${path.module}/scripts/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/scripts/index.html")

  depends_on = [module.frontend_website]
}

####################################################################
# S3 Bucket Policy for CloudFront OAC
####################################################################

resource "aws_s3_bucket_policy" "frontend_oac" {
  bucket = "csoft-wiseindex-app-prod-use1"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::csoft-wiseindex-app-prod-use1/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront_frontend.cloudfront_distribution_arn
          }
        }
      }
    ]
  })

  depends_on = [module.frontend_website, module.cloudfront_frontend]
}

module "cloudfront_frontend" {
  depends_on = [module.frontend_website]
  source     = "./modules/cloudfront"
  aliases    = ["frontend.holaamigoes.in"]
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
  web_acl_id                      = module.waf.web_acl_arn
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  origin = {
    s3-website = {
      domain_name           = module.frontend_website.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac"
    }
    wiseindex-origin = {
      domain_name = "wiseindex.holaamigoes.in"
      origin_id   = "wiseindex.csoft.internal"
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "http-only"
        origin_read_timeout      = 30
        origin_ssl_protocols     = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
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
    compress = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/wiseindex*"
      target_origin_id       = "wiseindex.csoft.internal"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false
      compress             = true

      cache_policy_id = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"

      lambda_function_association = {
        origin-request = {
          lambda_arn   = "arn:aws:lambda:us-east-1:675169529857:function:strip-wiseindex:1"
          include_body = false
        }
      }
    }
  ]

  custom_error_response = [
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 5
    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = module.acm_main.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}
