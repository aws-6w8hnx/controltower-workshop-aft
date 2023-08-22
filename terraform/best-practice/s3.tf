resource "aws_s3_bucket" "aft_workshop_bucket" {
  bucket = "aft-workshop-bucket-${local.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "aft_workshop_bucket_versioning" {
  bucket = aws_s3_bucket.aft_workshop_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "aft_workshop_bucket_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aft_workshop_bucket_sse" {
  bucket = aws_s3_bucket.aft_workshop_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.aft_workshop_bucket_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
