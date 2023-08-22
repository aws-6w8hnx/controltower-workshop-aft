resource "aws_dynamodb_table" "aft_workshop_backend_ddb_tfstate_lock" {
  name = "aft-workshop-backend-${local.account_id}-${region}-tfstate-lock"

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
