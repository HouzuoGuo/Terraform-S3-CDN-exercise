// dns.tf describes Route 53 zone record setup for blue/green production deployment.

data "aws_route53_zone" "business_dns" {
  name = "hz.gl."
}

/*
The record points to blue deployment.
For the CI/CD this resource would be managed by a workflow instead of a single declaration
of desired state.
The two CDN distributions will also require an operator to supply valid TLS certificate for
the domain name of "prod-exercise.hz.gl".
*/
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.business_dns.zone_id
  name    = "prod-exercise.${data.aws_route53_zone.business_dns.name}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.blue_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.blue_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
