data "aws_ssm_parameter" "auth_token" {
  name = "reds-auth-token"
}

resource "aws_elasticache_subnet_group" "subnet_group" {
  name = "${local.cluster_name}-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  description = "redis cluster group"
  replication_group_id = local.cluster_name
  node_type = "cache.t3.small"
  port = local.db_port
  parameter_group_name = "default.redis6.x.cluster.on"
  snapshot_retention_limit = 5
  snapshot_window = "00:00-05:00"
  subnet_group_name = aws_elasticache_subnet_group.subnet_group.name
  automatic_failover_enabled = true 
  security_group_ids = [aws_security_group.default.id,aws_security_group.client.id]
  auth_token = data.aws_ssm_parameter.auth_token.value
  transit_encryption_enabled = true
  replicas_per_node_group = local.num_node_groups
  num_node_groups = local.num_node_groups
}

resource "aws_ssm_parameter" "redis_host_url" {
  name        = "redis-host-url"
  description = "redis database host url parameter"
  type        = "String"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
  tags = {
    Environment = local.env
  }
}
