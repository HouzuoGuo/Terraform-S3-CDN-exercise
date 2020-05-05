/*
cdns.tf describes S3 buckets for blue/green deployment. The bucket policy exclusively allows
access from CDN themselves.
*/

resource "aws_s3_bucket" "blue_site_bucket" {
  bucket = "exercise-bucket-blue"
  acl    = "private"
}

data "aws_iam_policy_document" "blue_bucket_iam_policy" {
  statement {
    // TODO: Allow CodeBuild role to arbitrarily manipulate bucket content in order to deploy new code.
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.cdn_oai.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.blue_site_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "blue_bucket_policy" {
  bucket = aws_s3_bucket.blue_site_bucket.id
  policy = data.aws_iam_policy_document.blue_bucket_iam_policy.json
}

resource "aws_s3_bucket" "green_site_bucket" {
  bucket = "exercise-bucket-green"
  acl    = "private"
}

data "aws_iam_policy_document" "green_bucket_iam_policy" {
  statement {
    // TODO: Allow CodeBuild role to arbitrarily manipulate bucket content in order to deploy new code.
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.cdn_oai.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.green_site_bucket.arn}/*"]
  }
}
resource "aws_s3_bucket_policy" "green_bucket_policy" {
  bucket = aws_s3_bucket.green_site_bucket.id
  policy = data.aws_iam_policy_document.green_bucket_iam_policy.json
}
