# =============================================================================
# S3 Bucket (Active Storage用)
# =============================================================================
resource "aws_s3_bucket" "app" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "${var.project_name}-${var.environment}-storage"
  }
}

# =============================================================================
# S3 Bucket Versioning
# =============================================================================
resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =============================================================================
# S3 Bucket Encryption
# =============================================================================
resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# =============================================================================
# Block Public Access
# =============================================================================
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================================
# CORS Configuration (Active Storage用)
# =============================================================================
resource "aws_s3_bucket_cors_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"] # 本番環境では適切なドメインに制限
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# =============================================================================
# Lifecycle Policy (古いバージョンを削除)
# =============================================================================
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
