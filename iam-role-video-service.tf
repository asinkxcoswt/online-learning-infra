data "aws_caller_identity" "current" {}

resource "aws_iam_role" "video_service" {
  name               = "${var.name_prefix}-video-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" // set to more restrictive principal later
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

// allow Lambda to read/write video S3 bucket
resource "aws_iam_role_policy" "video_service_s3" {
  role = aws_iam_role.video_service.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = [
          "${aws_s3_bucket.videos-bucket.arn}/*"
        ]
      }
    ]
  })
}


// allow Lambda to read CloudFront signing key from SSM
resource "aws_iam_role_policy" "video_service_ssm" {
  role = aws_iam_role.video_service.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGetCFSigningKey",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.cf_signing_key_ssm_path_private}"
        ]
      }
    ]
  })
}

resource "aws_ssm_parameter" "video_service_role_arn" {
  name  = "/${var.name_prefix}/iam/video-service-role-arn"
  type  = "String"
  value = aws_iam_role.video_service.arn
}
