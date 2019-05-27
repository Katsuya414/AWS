variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "region" {
  default = "us-west-2"
}

provider "aws" {
    access_key = "${var.aws_access_key_id}"
    secret_key = "${var.aws_secret_access_key}"
    region = "${var.region}"
}

resource "aws_vpc" "vpc-1" {
  cidr_block = "10.0.0.0/16"
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
  subnet_id = "${aws_subnet.public-a.id}"
}

# InternetGateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc-1.id}"
}


# Subnet
resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.3.0.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "public-a"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.3.2.0/24"
  availability_zone = "us-west-2c"
  tags {
    Name = "public-c"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.3.4.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "private-a"
  }
}

resource "aws_subnet" "private-c" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.3.6.0/24"
  availability_zone = "us-west-2c"
  tags {
    Name = "private-c"
  }
}
