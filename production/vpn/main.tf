module "tailscale_vpn" {
  source = "../../modules/tailscale"
  env     = local.env
  region  = local.region
  tailnet = local.tailnet
  vpc_id = data.terraform_remote_state.vpc.outputs.id
  relayer_subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_1_id
  subnets_to_advertise = data.terraform_remote_state.vpc.outputs.private_subnet_cidrs
}

# Give access to DB through Security group
data "aws_security_group" "client" {
  name   = "pg-cluster-20221103192516479600000004"
  vpc_id = data.terraform_remote_state.vpc.outputs.id
}

resource "aws_security_group_rule" "client_write_db_sg" {
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = local.db_port
  to_port                  = local.db_port
  source_security_group_id = module.tailscale_vpn.security_group_id
  security_group_id        = data.aws_security_group.client.id
}
