## Create VPC
resource "aws_vpc" "net_vpc" {
  cidr_block           = local.net_vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  tags = {
    Name = "${local.net_vpc_name}"
  }
}

## Create Private Subnet
resource "aws_subnet" "net_private_subnets" {
  count                   = local.net_subnet_count
  vpc_id                  = aws_vpc.net_vpc.id
  cidr_block              = cidrsubnet("${local.net_vpc_cidr_block}", "${local.net_newbits}", "${count.index}")
  availability_zone       = var.net_priv_subnet_azs[count.index]
  map_public_ip_on_launch = "false"
  tags = {
    Name = "${var.net_env}-private-subnet-${var.net_priv_subnet_azs[count.index]}"
  }
}

## Create Public Subnets
resource "aws_subnet" "net_public_subnets" {
  count                   = local.net_subnet_count
  vpc_id                  = aws_vpc.net_vpc.id
  cidr_block              = cidrsubnet("${local.net_vpc_cidr_block}", "${local.net_newbits}", "${count.index + length(var.net_priv_subnet_azs)}")
  availability_zone       = var.net_priv_subnet_azs[count.index]
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.net_env}-public-subnet-${var.net_priv_subnet_azs[count.index]}"
  }
}

## Create Internet Gateway + Resources
resource "aws_internet_gateway" "net_vpc_igw" {
  vpc_id = aws_vpc.net_vpc.id
  tags = {
    Name = "${var.net_env}-igw"
  }
}

## Create EIP
resource "aws_eip" "net_eip" {
  vpc = true
  tags = {
    Name = "${var.net_env}_eip"
  }
  depends_on = [
    aws_internet_gateway.net_vpc_igw
  ]
}

## Create NAT GW
resource "aws_nat_gateway" "net_nat_gw" {
  allocation_id = aws_eip.net_eip.id
  subnet_id     = aws_subnet.net_public_subnets[0].id
  tags = {
    Name = "${var.net_env}-nat_gw"
  }
}

## Public Route Table & Associations
resource "aws_route_table" "net_public_subnet_to_igw_rtb" {
  vpc_id = aws_vpc.net_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.net_vpc_igw.id
  }
  tags = {
    Name = "${var.net_env}-public_subnets->net_igw-rtb"
  }
}

resource "aws_route_table_association" "associate_1" {
  count          = local.net_subnet_count
  subnet_id      = element(aws_subnet.net_public_subnets.*.id, count.index)
  route_table_id = aws_route_table.net_public_subnet_to_igw_rtb.id
}

## Private Network Route table association
resource "aws_route_table" "net_private_subnet_to_ngw_rtb" {
  vpc_id = aws_vpc.net_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.net_nat_gw.id
  }
  tags = {
    Name = "${var.net_env}-private_subnets->nat_gw_rtb"
  }
}

resource "aws_route_table_association" "associate_2" {
  count          = local.net_subnet_count
  subnet_id      = aws_subnet.net_private_subnets[count.index].id
  route_table_id = aws_route_table.net_private_subnet_to_ngw_rtb.id
}

output "private_subnet_ids" {
  value = aws_subnet.net_private_subnets[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.net_public_subnets[*].id
}
