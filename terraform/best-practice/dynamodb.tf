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
