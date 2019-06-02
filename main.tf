variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "region" {}

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "vpc-1" {
  cidr_block = "10.3.0.0/16"
  tags = {
    Name = "vpc-1"
  }
}

# EIP
resource "aws_eip" "nat" {
  vpc = true
}


# NatGateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.private.id}"
}



# InternetGateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc-1.id}"
}


# Subnet
resource "aws_subnet" "public-a" {
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "10.3.0.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "10.3.2.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "public-c"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "10.3.4.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "private-a"
  }
}

resource "aws_subnet" "private-c" {
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "10.3.6.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "private-c"
  }
}



# RouteTable
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }
  tags = {
    Name = "private"
  }
}

# SubnetRouteTableAssociation
resource "aws_route_table_association" "public-a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = "${aws_subnet.public-c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = "${aws_subnet.private-a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-c" {
  subnet_id      = "${aws_subnet.private-c.id}"
  route_table_id = "${aws_route_table.private.id}"
}
