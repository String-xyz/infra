locals {
  remote_state_bucket  = "dev-string-terraform-state"
  backend_region       = "us-west-2"
  vpc_remote_state_key = "vpc.tfstate"
  
  cluster_name          = "redis"
  env                   = "dev"
  db_port               = 6379
  num_node_groups       = 1
  region                = "us-west-2"
}
