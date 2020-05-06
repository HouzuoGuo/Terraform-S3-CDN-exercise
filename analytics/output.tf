// prod_waf_stream_arn is consumed by production WAF of application infrastructure resources deployed in EU.
output "prod_waf_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.prod_waf_stream.arn
}
