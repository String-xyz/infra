locals {
  region           = "us-west-2"
  state_region     = "us-east-1"
  # lets start with an small instance for now
  # if we feel is not cutting it for us later, we can upgrade to medium or large.
  instance_type    = "db.t3.small"
  db_port          = "5432"
  write_identifier = "string-write-master"
  read_identifier  = "string-read-replica"
  storage_type     = "gp2"
  multi_az         = true
  env              = "sandbox"
}

data "aws_kms_alias" "kms_key" {
   name = "alias/main-kms-key"
 }

data "aws_ssm_parameter" "password" {
  name = "${local.env}-rds-pg-db-password"
}

data "aws_ssm_parameter" "username" {
  name = "${local.env}-rds-pg-db-username"
}

data "aws_ssm_parameter" "db_name" {
  name = "${local.env}-rds-pg-db-name"
}

module "write" {
  source            = "../../modules/rds"
  env               = local.env
  vpc_id            = data.terraform_remote_state.vpc.outputs.id
  subnets           = data.terraform_remote_state.vpc.outputs.private_subnets.*
  name              = local.write_identifier
  identifier        = "${local.env}-${local.write_identifier}"
  db_username       = data.aws_ssm_parameter.username.value
  db_name           = data.aws_ssm_parameter.db_name.value
  db_password       = data.aws_ssm_parameter.password.value
  db_port           = local.db_port
  db_engine         = "postgres"
  engine_version    = "14.2"
  instance_class    = local.instance_type
  allocated_storage = 10
  storage_size      = 200
  tags              = { Environment = local.env }
  kms_key_id        = data.aws_kms_alias.kms_key.arn
  param_group_name  = "default.postgres14"
  multi_az          = false
  allow_public_access = false
  storage_type      = local.storage_type
}

resource "aws_ssm_parameter" "db_write_host" {
  name        = "${local.env}-write-db-host-url"
  description = "master sandbox write database host url parameter"
  type        = "SecureString"
  value       = module.write.host
  key_id      = data.aws_kms_alias.kms_key.arn
  tags = {
    Environment = local.env
  }
}
