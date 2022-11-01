provider "aws" {
  region = "us-west-2"
}

terraform {
  required_providers {
    aws = { 
      source = "hashicorp/aws"
      version = "4.37.0"
    }
  }

  backend "s3" {
    region  = "us-west-2"
    key     = "backend.tfstate" # terraform backend state file
    bucket  = "prod-string-terraform-state"
  }
}

# dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb" {
  name           = "prod-string-terraform-state-lock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
    Environment = "prod"
  }
}
