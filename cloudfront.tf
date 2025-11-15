data "aws_ssm_parameter" "cloudfront_public_key_pem" {
  name           = var.cf_signing_key_ssm_path
  with_decryption = true
}

resource "aws_cloudfront_public_key" "signing_cf_key" {
  name        = "${var.name_prefix}-signing-cloudfront-public-key"
  comment     = "Public key derived from signing asymmetric key"
  encoded_key = data.aws_ssm_parameter.cloudfront_public_key_pem.value
}

resource "aws_cloudfront_key_group" "signing_key_group" {
  name    = "${var.name_prefix}-signing-cloudfront-key-group"
  comment = "Key group using signing-backed public key"

  items = [
    aws_cloudfront_public_key.signing_cf_key.id
  ]
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "video-oac"
  description                       = "OAC for private S3 video bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "video_cdnx" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.videos-bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    # 👇 tell CloudFront this behavior is protected by the key group
    trusted_key_groups = [aws_cloudfront_key_group.signing_key_group.id]
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_ssm_parameter" "cloudfront_domain" {
  name        = "/${var.name_prefix}/cloudfront/domain"
  type        = "String"
  value = aws_cloudfront_distribution.video_cdnx.domain_name
}

resource "aws_ssm_parameter" "cloudfront_signing_public_key_id" {
  name  = "/${var.name_prefix}/cloudfront/signing-key-id"
  type  = "String"
  value = aws_cloudfront_public_key.signing_cf_key.id
}
