provider.tf  :-

provider "aws" {
  region  = "us-east-1"
  profile = "tf-pro"

}

main.tf  :-

resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "TerraVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "main"
  }
}

# Subnets : public
resource "aws_subnet" "public" {
  count                   = length(var.public_cidr)
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = element(var.public_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.namespace}-Subnet-${count.index + 1}" })
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count          = length(var.public_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}


variable.tf  :-

variable "vpc_cidr" {

}

variable "public_cidr" {

}

variable "azs" {

}

variable "tags" {

}

variable "namespace" {

}


dev.auto.tfvars  :-

vpc_cidr    = "10.0.0.0/16"
public_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
azs         = ["us-east-1a", "us-east-1b"]
tags = {
  Name = "INS"
}
namespace = "Dev"
