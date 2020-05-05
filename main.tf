// main.tf describes backend and output. Infrastructure resources are described in other *.tf files.
provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

terraform {
  backend "s3" {
    region = "eu-north-1"
    bucket = "exercise-tf-states"
    key    = "global/s3/terraform.tfstate"
  }
}

output "blue_cdn_domain_name" {
  value       = aws_cloudfront_distribution.blue_cdn.domain_name
  description = "Internet domian name of the blue deployment CDN"
}

output "green_cdn_domain_name" {
  value       = aws_cloudfront_distribution.green_cdn.domain_name
  description = "Internet domian name of the green deployment CDN"
}
