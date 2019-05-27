variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "region" {
  default = "us-west-2"
}

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_vpc" "vpc-1" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "vpc-1"
  }
}
