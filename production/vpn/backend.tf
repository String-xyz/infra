locals {
  state_bucket  = "prod-string-terraform-state"
  vpc_state_key = "vpc.tfstate"
}

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
    encrypt        = true
    key            = "string-vpn.tfstate"
    bucket         = "prod-string-terraform-state"
    dynamodb_table = "prod-string-terraform-state-lock"
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
