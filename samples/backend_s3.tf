terraform {
  backend "s3" {
    bucket         = "aft-workshop-backend-us-east-1-123456789012-s3"
    key            = "tfstate/best-practice.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
    dynamodb_table = "aft-workshop-backend-us-east-1-123456789012-ddb"
  }
}