# VPC
resource "aws_vpc" "task1" {
  cidr_block = var.vpc_cidr
  
  tags = merge(var.tags, {
    Name     = "vpc-task1-${var.name_suffix}"
  })
}

# Public subnets
resource "aws_subnet" "task1_public_subnet" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.task1.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}-${var.name_suffix}"
    Type = "public"
  }
}

# Private subnets
resource "aws_subnet" "task1_private_subnet" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.task1.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index + 1}-${var.name_suffix}"
    Type = "private"
  }
}

# adding internet gateway for external communication
resource "aws_internet_gateway" "task1_internet_gateway" {
  provider = aws
  vpc_id = aws_vpc.task1.id

  tags = {
    Name        = "igw-${var.name_suffix}"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# create external route to IGW
resource "aws_route" "external_route" {
  provider               = aws
  route_table_id         = aws_vpc.task1.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.task1_internet_gateway.id
}