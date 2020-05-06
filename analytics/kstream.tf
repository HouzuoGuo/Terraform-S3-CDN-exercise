// kstream.tf describes the streaming collection and analytics infrastructure for web request logs.

/*
prod_waf_stream receives stream of request logs from WAF and transports them to S3 bucket for further
analysis and archival. A small buffer size is deliberately chosen as the startup's project is still
undergoing heavy development.
*/
resource "aws_kinesis_firehose_delivery_stream" "prod_waf_stream" {
  name        = "aws-waf-logs-prod-waf"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.waf_log_firehose_role.arn
    bucket_arn      = aws_s3_bucket.waf_log_bucket.arn
    buffer_size     = 1
    buffer_interval = 60
  }
}

// waf_log_bucket stores request logs from WAF.
resource "aws_s3_bucket" "waf_log_bucket" {
  bucket = "exercise-prod-waf-log"
  acl    = "private"
}

// waf_log_firehose_role grants AWS Firehose access to the request log bucket. See policy attachment.
resource "aws_iam_role" "waf_log_firehose_role" {
  name               = "exercise_waf_log_firehose_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "waf_log_firehose_role_attachment" {
  role       = "${aws_iam_role.waf_log_firehose_role.name}"
  policy_arn = "${aws_iam_policy.waf_log_bucket_access.arn}"
}

// waf_log_bucket_access grants bearer full access to the request log bucket.
resource "aws_iam_policy" "waf_log_bucket_access" {
  name   = "exercise_waf_log_firehose_bucket_access"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["s3:*"],
      "Effect": "Allow",
      "Resource": [ "${aws_s3_bucket.waf_log_bucket.arn}/*" ]
    }
  ]
}
EOF
}
