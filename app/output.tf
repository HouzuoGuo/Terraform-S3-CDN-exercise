output "blue_cdn_domain_name" {
  value       = aws_cloudfront_distribution.blue_cdn.domain_name
  description = "Internet domian name of the blue deployment CDN"
}

output "green_cdn_domain_name" {
  value       = aws_cloudfront_distribution.green_cdn.domain_name
  description = "Internet domian name of the green deployment CDN"
}

