resource "aws_security_group" "tailscale" {
  name = "${var.env}-tailscale-sg"
  description = "Allow tailscale relay vpc inbound traffic"
  vpc_id = var.vpc_id

  # Allow egress to the internet
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-tailscale-relay"
  }
}
