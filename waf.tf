// wafs.tf describes web application firewall ACL shared by both blue and green CloudFront distributions.

resource "aws_waf_rate_based_rule" "prod_rate_limit" {
  name        = "prod_rate_limit"
  metric_name = "ProdRateLimit"
  rate_key    = "IP"
  rate_limit  = 100
}

resource "aws_waf_web_acl" "prod_waf" {
  depends_on  = ["aws_waf_rate_based_rule.prod_rate_limit"]
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
}
