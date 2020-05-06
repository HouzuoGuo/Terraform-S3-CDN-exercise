// buckets.tf describes S3 buckets for blue/green deployment.

// blue_site_bucket is the S3 bucket storing the blue copy of application source code.
resource "aws_s3_bucket" "blue_site_bucket" {
  bucket = "exercise-bucket-blue"
  acl    = "private"
}

// blue_bucket_iam_policy allows CloudFront exclusive access to the blue bucket.
// TODO: allow CodeBuild to arbitrarily manipulate bucket content in order to deploy new code.
data "aws_iam_policy_document" "blue_bucket_iam_policy" {
  statement {
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

// blue_site_bucket is the S3 bucket storing the green copy of application source code.
resource "aws_s3_bucket" "green_site_bucket" {
  bucket = "exercise-bucket-green"
  acl    = "private"
}

// green_bucket_iam_policy allows CloudFront exclusive access to the green bucket.
// TODO: allow CodeBuild to arbitrarily manipulate bucket content in order to deploy new code.
data "aws_iam_policy_document" "green_bucket_iam_policy" {
  statement {
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
