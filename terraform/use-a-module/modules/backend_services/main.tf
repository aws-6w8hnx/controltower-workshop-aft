locals {
    account_id        = data.aws_caller_identity.current.account_id
    region            = data.aws_region.current.name
    naming_convention = "${var.project}-${var.env}-${var.service}-${local.region}-${local.account_id}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "aft_workshop_bucket" {
  bucket = "${local.naming_convention}-s3"
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

resource "aws_dynamodb_table" "aft_workshop_backend_ddb_tfstate_lock" {
  name = "${local.naming_convention}-ddb"

  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    auto-delete = "no"
  }
}
