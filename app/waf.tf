// wafs.tf describes web application firewall ACL shared by both blue and green CloudFront distributions.

/*
prod_waf_stream_arn is the ARN of Firehose delivery stream for production request logging.
It is fed by analytics module output.
*/
variable "prod_waf_stream_arn" {
  type        = string
  description = "The ARN of Firehose delivery stream for production request logging."
}

// prod_rate_limit imposes a 20 requests/minue rate limit for each visitor.
// (Thanks to https://github.com/heldersepu for a tip!)
resource "aws_waf_rate_based_rule" "prod_rate_limit" {
  name        = "prod_rate_limit"
  metric_name = "ProdRateLimit"
  rate_key    = "IP"
  rate_limit  = 100
}

/*
prod_waf is a web application firewall imposing a request rate limit for both blue and green CloudFront distros.
For analytical purposes, the firewall sends visitor's request log to a Firehose stream.
*/
resource "aws_waf_web_acl" "prod_waf" {
  depends_on  = [aws_waf_rate_based_rule.prod_rate_limit]
  name        = "prod_waf"
  metric_name = "ProdWAF"
  default_action {
    type = "ALLOW"
  }
  rules {
    priority = 1
    action {
      type = "BLOCK"
    }
    type    = "RATE_BASED"
    rule_id = aws_waf_rate_based_rule.prod_rate_limit.id
  }
  // On 2020-05-06, AWS runs into internal server error when it attempts to enable this logging configuration.
  logging_configuration {
    log_destination = var.prod_waf_stream_arn
  }
}
