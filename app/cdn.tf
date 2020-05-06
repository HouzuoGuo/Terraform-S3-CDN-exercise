// cdns.tf describes CloudFront production distributions for blue/green deployment.

locals {
  blue_cdn_origin_id  = "blue_bucket_origin"
  green_cdn_origin_id = "green_bucket_origin"
}

// cdn_oai is CloudFront's IAM identity to which exclusive access to source code buckets is granted.
resource "aws_cloudfront_origin_access_identity" "cdn_oai" {
}

// blue_cdn serves the blue copy of source code to global visitors.
resource "aws_cloudfront_distribution" "blue_cdn" {
  enabled    = true
  web_acl_id = aws_waf_web_acl.prod_waf.id
  // aliases = ["exercise-prod.hz.gl"] // an operator needs to supply a valid TLS certificate for this domain name
  origin {
    domain_name = aws_s3_bucket.blue_site_bucket.bucket_regional_domain_name
    origin_id   = local.blue_cdn_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn_oai.cloudfront_access_identity_path
    }
  }
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.blue_cdn_origin_id
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

// green_cdn serves the green copy of source code to global visitors.
resource "aws_cloudfront_distribution" "green_cdn" {
  enabled    = true
  web_acl_id = aws_waf_web_acl.prod_waf.id
  // aliases = ["exercise-prod.hz.gl"] // an operator needs to supply a valid TLS certificate for this domain name
  origin {
    domain_name = aws_s3_bucket.green_site_bucket.bucket_regional_domain_name
    origin_id   = local.green_cdn_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn_oai.cloudfront_access_identity_path
    }
  }
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.green_cdn_origin_id
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
