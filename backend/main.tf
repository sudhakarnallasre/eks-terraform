provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "demo-terraform-eks-state-file-18819"

    lifecycle {
      prevent_destroy = false
    }
    
  }

resource "aws_dynamodb_table" "dynamo_db" {
  name         = "terraform-eks-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}