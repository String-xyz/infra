provider "aws" {
  region = "us-west-2"
}

terraform {
  required_providers {
    aws = { 
      source = "hashicorp/aws"
      version = "4.14.0"
    }
  }

  backend "s3" {
    encrypt        = true
    key            = "redis.tfstate"
    bucket         = "dev-string-terraform-state"
    dynamodb_table = "dev-string-terraform-state-lock"
    region         = "us-west-2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = local.backend_region
    bucket = local.remote_state_bucket
    key    = local.vpc_remote_state_key
  }
}
