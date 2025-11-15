resource "aws_s3_bucket" "videos-bucket" {
  bucket = "${var.name_prefix}-videos-bucket"
}

resource "aws_s3_bucket_ownership_controls" "videos-bucket" {
  bucket = aws_s3_bucket.videos-bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# (optional) Block all public access
resource "aws_s3_bucket_public_access_block" "videos-bucket" {
  bucket = aws_s3_bucket.videos-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "video_bucket_policy" {
  statement {
    sid    = "AllowCloudFront"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.videos-bucket.id}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.video_cdnx.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "video" {
  bucket = aws_s3_bucket.videos-bucket.id
  policy = data.aws_iam_policy_document.video_bucket_policy.json
}

resource "aws_ssm_parameter" "video-bucket-name" {
  name  = "/${var.name_prefix}/s3/video-bucket-name"
  type  = "String"
  value = aws_s3_bucket.videos-bucket.id
}