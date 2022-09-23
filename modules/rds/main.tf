resource "aws_db_subnet_group" "rds_subnet_group" {
  count      = var.replicate_source_db == null ? 1 : 0
  name       = "${var.env}-${var.name}-subnet-group-rds"
  subnet_ids = var.subnets
}

resource "aws_security_group" "client" {
  name        = "${var.env}-${var.name}-client-rds"
  description = "Default client security group to allow inboud"
  vpc_id      = var.vpc_id
}

# Client to RDS
resource "aws_security_group" "default" {
  name        = "${var.env}-${var.name}-default-rds"
  description = "allow inbound access from client sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.db_port
    to_port         = var.db_port
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM role to allow enhanced monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix        = "rds-enhanced-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_db_instance" "this" {
  identifier                            = var.identifier
  replicate_source_db                   = var.replicate_source_db
  username                              = var.db_username
  db_name                               = var.db_name
  password                              = var.db_password
  port                                  = var.db_port
  engine                                = var.db_engine
  engine_version                        = var.engine_version
  instance_class                        = var.instance_class
  allocated_storage                     = var.allocated_storage
  max_allocated_storage                 = var.storage_size
  tags                                  = var.tags
  kms_key_id                            = var.kms_key_id
  parameter_group_name                  = var.param_group_name
  multi_az                              = var.multi_az
  storage_type                          = var.storage_type
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  final_snapshot_identifier             = length(aws_db_subnet_group.rds_subnet_group) > 0 ? "${var.env}-${var.name}-final-snapshot" : null
  storage_encrypted                     = true
  vpc_security_group_ids                = ["${aws_security_group.default.id}","${aws_security_group.client.id}"]
  db_subnet_group_name                  = length(aws_db_subnet_group.rds_subnet_group) > 0 ? aws_db_subnet_group.rds_subnet_group[0].name : null
  publicly_accessible                   = var.allow_public_access
  allow_major_version_upgrade           = false
  auto_minor_version_upgrade            = true
  apply_immediately                     = true
  maintenance_window                    = "sun:02:00-sun:04:00"
  skip_final_snapshot                   = length(aws_db_subnet_group.rds_subnet_group) > 0 ? false : true # skip it only if this rds is a replication
  copy_tags_to_snapshot                 = true
  backup_retention_period               = length(aws_db_subnet_group.rds_subnet_group) > 0 ? 14 : null
  backup_window                         = length(aws_db_subnet_group.rds_subnet_group) > 0 ? "04:00-06:00" : null
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 30
  monitoring_role_arn                   = aws_iam_role.rds_enhanced_monitoring.arn
}
