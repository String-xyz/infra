locals {
  state_bucket  = "dev-string-terraform-state"
  vpc_state_key = "vpc.tfstate"
}

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
    key            = "string-vpn.tfstate"
    bucket         = "dev-string-terraform-state"
    dynamodb_table = "dev-string-terraform-state-lock"
    region         = "us-west-2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "us-west-2"
    bucket = local.state_bucket
    key    = local.vpc_state_key
  }
}
