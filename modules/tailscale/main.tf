// created manually through aws console
data "aws_ssm_parameter" "tailscale_api_key" {
  name  =  "${var.env}-tailscale-api-key"
}

resource "aws_instance" "tailscale-relay" {
  ami = "ami-0892d3c7ee96c0bf7"
  instance_type = "t3.small"
  subnet_id = var.relayer_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tailscale.id]

  lifecycle {
    create_before_destroy = true
  }

  user_data = templatefile("${path.module}/tailscale-relay-init.sh.tpl", {
    subnets_to_advertise = join(",", var.subnets_to_advertise)
    tailscale_api_key = data.aws_ssm_parameter.tailscale_api_key.value 
    prefix = var.env
    tailnet = var.tailnet
    tailnet_device_name = "aws-subnet-router"
  })

  tags = {
    Name = "${var.env}-tailscale-relay"
  }
}
