resource "aws_security_group" "bastion_sg" {
  name   = "${local.env}-bastion-host"
  vpc_id = data.terraform_remote_state.vpc.outputs.id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
     cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.env}-bastion-host"
    Environment = local.env
  }
}

resource "aws_iam_role" "role" {
  name               = "${local.env}-bastion-host-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "ssm.amazonaws.com" ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "user_connect" {
  name        = "${local.env}-bastion-user-instance-connect"
  path        = "/"
  description = "Allows use of EC2 instance connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  		"Effect": "Allow",
  		"Action": "ec2-instance-connect:SendSSHPublicKey",
  		"Resource": "${aws_instance.bastion.arn}",
  		"Condition": {
  			"StringEquals": { "ec2:osuser": "ec2-user" }
  		}
  	},
		{
			"Effect": "Allow",
			"Action": "ec2:DescribeInstances",
			"Resource": "*"
		}
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "instance_connect" {
  name       = "${local.env}-bastion-instance-connect-policy"
  policy_arn = aws_iam_policy.user_connect.arn
  groups     = [local.env]
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "profile" {
  name = "${local.env}-bastion-instance-profile"
  role = aws_iam_role.role.id
}

resource "aws_instance" "bastion" {
  ami                         = "ami-06c94f9acb4ba21b2"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnets.0
  vpc_security_group_ids      = ["${aws_security_group.bastion_sg.id}"]
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  key_name                    = "string_dev_ops"

  tags = {
    Name        = "${local.env}-bastion-host"
    Environment = local.env
  }
}

####
# Uncomment once postgres has been created
###

# data "aws_security_group" "rds_write_client_sg" {
#   name   = "${local.env}-string-write-master-client-RDS"
#   vpc_id = data.terraform_remote_state.vpc.outputs.id
# }

# resource "aws_security_group_rule" "bastion_to_client_write_db_sg" {
#   type                     = "ingress"
#   protocol                 = "TCP"
#   from_port                = local.db_port
#   to_port                  = local.db_port
#   source_security_group_id = aws_security_group.bastion_sg.id
#   security_group_id        = data.aws_security_group.rds_write_client_sg.id
# }
