variable "env" {
  description = "deployment environment"
}
variable "region" {
  description = "aws deployment region"
}

variable "tailnet" {
  description = "tailscale tailnet name"
}
variable "vpc_id" {
  description = "aws vpc id"
}
variable "relayer_subnet_id" {
  description = "aws subnet id for ec2 relayer"
}
variable "subnets_to_advertise" {
  description = "array of cidr blocks for tailscale relayer to advertise"
}
