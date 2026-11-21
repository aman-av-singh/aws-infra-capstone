provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "logs" {
  bucket        = "aman-p22-log-archive-2026"
  force_destroy = true
}

resource "aws_s3_object" "log1" {
  bucket = aws_s3_bucket.logs.id
  key    = "logs/app-2026-11-20.log"
  source = "app-2026-11-20.log"
}

resource "aws_s3_object" "log2" {
  bucket = aws_s3_bucket.logs.id
  key    = "logs/app-2026-11-21.log"
  source = "app-2026-11-21.log"
}

resource "aws_s3_bucket_lifecycle_configuration" "rule" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "archive-and-expire-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}