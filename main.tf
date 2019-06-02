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
    Name = "vpc-katuo"
  }
}


resource "aws_subnet" "public1a" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.vpc-1.cidr_block, 8, 0)}"
  availability_zone = "us-west-2a"

  tags = {
    Name = "$public1a"
  }
}

resource "aws_subnet" "public1c" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.vpc-1.cidr_block, 8, 1)}"
  availability_zone = "us-west-2c"

  tags = {
    Name = "public1c"
  }
}


resource "aws_subnet" "nat-private1a" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.vpc-1.cidr_block, 8, 4)}"
  availability_zone = "us-west-2a"

  tags = {
    Name = "nat-private1a"
  }
}

resource "aws_subnet" "nat-private1c" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.vpc-1.cidr_block, 8, 5)}"
  availability_zone = "us-west-2c"

  tags = {
    Name = "nat-private1c"
  }
}



resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags = {
    Name = "gateway"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_gateway.id}"
  subnet_id     = "${aws_subnet.public1a.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}


resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "nat-private" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  tags = {
    Name = "nat-private"
  }
}



resource "aws_route_table_association" "public1a" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public1a.id}"
}

resource "aws_route_table_association" "public1c" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public1c.id}"
}

resource "aws_route_table_association" "nat-private1a" {
  route_table_id = "${aws_route_table.nat-private.id}"
  subnet_id      = "${aws_subnet.nat-private1a.id}"
}

resource "aws_route_table_association" "nat-private1c" {
  route_table_id = "${aws_route_table.nat-private.id}"
  subnet_id      = "${aws_subnet.nat-private1c.id}"
}
