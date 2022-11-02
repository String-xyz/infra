locals {
  region        = "us-west-2"
  state_region  = "us-east-1"
  instance_type = "db.r6g.large"
  db_port       = "5432"
  name          = "pg-cluster"
  env           = "prod"
}

data "aws_kms_alias" "kms_key" {
  name = "alias/main-kms-key"
}

data "aws_ssm_parameter" "db_password" {
  name = "string-pg-db-password"
}

data "aws_ssm_parameter" "db_username" {
  name = "string-pg-db-username"
}

data "aws_ssm_parameter" "db_name" {
  name = "string-pg-db-name"
}

resource "aws_security_group" "client_security_group" {
  name   = "${local.name}-client-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.id
}

resource "aws_db_parameter_group" "pm_group" {
  name_prefix = "${local.name}-db-postgres14-parameter-group"
  family      = "aurora-postgresql14"
  description = "${local.name}-aurora-db-postgres14-parameter-group"
  tags        = { Environment = local.env }
}

resource "aws_rds_cluster_parameter_group" "cluster_pm_group" {
  name_prefix = "${local.name}-postgres14-cluster-parameter-group"
  family      = "aurora-postgresql14"
  description = "${local.name}-postgres14-cluster-parameter-group"
  tags        = { Environment = local.env }
}

module "cluster" {
  source                          = "terraform-aws-modules/rds-aurora/aws"
  name                            = local.name
  engine                          = "aurora-postgresql"
  engine_version                  = "14"
  instance_class                  = local.instance_type
  instances                       = { 1 = {} }
  master_password                 = data.aws_ssm_parameter.db_password.value
  master_username                 = data.aws_ssm_parameter.db_username.value
  database_name                   = data.aws_ssm_parameter.db_name.value
  vpc_id                          = data.terraform_remote_state.vpc.outputs.id
  create_random_password          = false
  create_db_subnet_group          = true
  create_security_group           = true
  allowed_security_groups         = [aws_security_group.client_security_group.id]
  autoscaling_enabled             = true
  autoscaling_min_capacity        = 1
  autoscaling_max_capacity        = 5
  monitoring_interval             = 60
  iam_role_name                   = "${local.name}-monitor"
  iam_role_use_name_prefix        = true
  iam_role_description            = "${local.name} RDS enhanced monitoring IAM role"
  iam_role_path                   = "/autoscaling/"
  iam_role_max_session_duration   = 7200
  kms_key_id                      = data.aws_kms_alias.kms_key.id
  storage_encrypted               = true
  apply_immediately               = true
  skip_final_snapshot             = true
  subnets                         = data.terraform_remote_state.vpc.outputs.private_subnets.*
  db_parameter_group_name         = aws_db_parameter_group.pm_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_pm_group.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = { Environment = local.env }
}

resource "aws_ssm_parameter" "write_host" {
  name        = "pg-cluster-write-host-url"
  description = "cluster string write database host url parameter"
  type        = "String"
  value       = module.cluster.cluster_endpoint
  tags = {
    Environment = local.env
  }
}

resource "aws_ssm_parameter" "read_host" {
  name        = "pg-cluster-read-host-url"
  description = "cluster string read database host url parameter"
  type        = "String"
  value       = module.cluster.cluster_reader_endpoint
  tags = {
    Environment = local.env
  }
}
