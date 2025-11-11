resource "aws_s3_bucket" "videos-bucket" {
  bucket = "${var.name_prefix}-videos-bucket"
}

resource "aws_s3_bucket_ownership_controls" "videos-bucket" {
  bucket = aws_s3_bucket.videos-bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# resource "aws_s3_bucket_versioning" "private" {
#   bucket = aws_s3_bucket.private.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# Enable server-side encryption (AES-256)
# resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
#   bucket = aws_s3_bucket.private.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# (optional) Block all public access
resource "aws_s3_bucket_public_access_block" "videos-bucket" {
  bucket = aws_s3_bucket.videos-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

