output "id" {
  value = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "public_subnet_3_id" {
  value = aws_subnet.public_subnet_3.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "private_subnet_3_id" {
  value = aws_subnet.private_subnet_3.id
}

output "public_subnets" {
  value = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
}

output "private_subnets" {
  value = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
}

output "public_subnet_cidrs" {
  value = [ local.public_subnet_1_cidr, local.public_subnet_2_cidr, local.public_subnet_3_cidr ]
}

output "private_subnet_cidrs" {
  value = [ local.private_subnet_1_cidr, local.private_subnet_2_cidr, local.private_subnet_3_cidr ]
}
