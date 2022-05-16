locals {
  env      = "dev"
  project  = "string"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_1_cidr  = "10.0.1.0/24"
  public_subnet_2_cidr  = "10.0.2.0/24"
  public_subnet_3_cidr  = "10.0.3.0/24"
  private_subnet_1_cidr = "10.0.4.0/24"
  private_subnet_2_cidr = "10.0.5.0/24"
  private_subnet_3_cidr = "10.0.6.0/24"
}

resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${local.project}-vpc"
    Environment = local.env
  }
}

resource "aws_subnet" "public_subnet_1" {
  cidr_block        = local.public_subnet_1_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "${local.project}-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block        = local.public_subnet_2_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2b"
  tags = {
    Name = "${local.project}-public-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  cidr_block        = local.public_subnet_3_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2c"
  tags = {
    Name = "${local.project}-public-subnet-3"
  }
}

resource "aws_subnet" "private_subnet_1" {
  cidr_block        = local.private_subnet_1_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "${local.project}-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  cidr_block        = local.private_subnet_2_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2b"
  tags = {
    Name = "${local.project}-private-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  cidr_block        = local.private_subnet_3_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2c"
  tags = {
    Name = "${local.project}-private-subnet-3"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.project}-public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.project}-private-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_3.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_2.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_3.id
}

resource "aws_eip" "eip_for_nat_gw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "${local.project}-vpc-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_for_nat_gw.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "${local.project}-vpc-nat-gw"
  }
  depends_on = [
    aws_eip.eip_for_nat_gw,
  ]
}

resource "aws_route" "nat_gw_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.project}-vpc-igw"
  }
}

resource "aws_route" "public_internet_gw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
