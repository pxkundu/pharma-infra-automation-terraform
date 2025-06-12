locals {
  name = "${var.project_name}-${var.environment}"
}

# S3 bucket for AWS Config
resource "aws_s3_bucket" "config" {
  bucket = "${local.name}-config-logs"

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-config-logs"
    }
  )
}

# S3 bucket policy for AWS Config
resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id
  policy = data.aws_iam_policy_document.config_s3.json
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    id     = "cleanup_old_logs"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# AWS Config
resource "aws_config_configuration_recorder" "main" {
  name     = "${local.name}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported = true
    include_global_resources = true
  }
}

# AWS Config delivery channel
resource "aws_config_delivery_channel" "main" {
  name           = "${local.name}-config-delivery"
  s3_bucket_name = aws_s3_bucket.config.bucket
  s3_key_prefix  = "config"

  depends_on = [aws_config_configuration_recorder.main]
}

# IAM role for AWS Config
resource "aws_iam_role" "config" {
  name = "${local.name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for AWS Config
resource "aws_iam_role_policy" "config" {
  name = "${local.name}-config-policy"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.config.arn}/*"
        ]
        Condition = {
          StringLike = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl"
        ]
        Resource = aws_s3_bucket.config.arn
      }
    ]
  })
}

# S3 bucket policy document
data "aws_iam_policy_document" "config_s3" {
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com"
      ]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.config.arn
    ]
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com"
      ]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.config.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }
} 