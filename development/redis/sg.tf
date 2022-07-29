resource "aws_security_group" "default" {
  name   = "${local.cluster_name}-redis-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.id
  
  ingress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "TCP"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${local.cluster_name}-redis-sg"
    environment = local.env
  }
}

resource "aws_security_group" "client" {
  name        = "${local.cluster_name}-client-redis"
  description = "Default client security group to allow inboud"
  vpc_id      = data.terraform_remote_state.vpc.outputs.id
}
