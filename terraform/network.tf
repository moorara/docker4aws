resource "aws_vpc" "d4aws" {
  cidr_block = "${lookup(var.vpc_cidrs, var.region)}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "d4aws"
    Environment = "${var.environment}"
    Region = "${var.region}"
  }
}

resource "aws_subnet" "d4aws" {
  count = "${length(data.aws_availability_zones.d4aws.names)}"
  vpc_id = "${aws_vpc.d4aws.id}"
  cidr_block = "${cidrsubnet(aws_vpc.d4aws.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.d4aws.names[count.index]}"
  map_public_ip_on_launch = false
  tags {
    Name = "d4aws-${count.index}"
    Environment = "${var.environment}"
    Region = "${var.region}"
  }
}

resource "aws_internet_gateway" "d4aws" {
  vpc_id = "${aws_vpc.d4aws.id}"
  tags {
    Name = "d4aws"
    Environment = "${var.environment}"
    Region = "${var.region}"
  }
}

resource "aws_route_table" "d4aws" {
  vpc_id = "${aws_vpc.d4aws.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.d4aws.id}"
  }
  tags {
    Name = "d4aws"
    Environment = "${var.environment}"
    Region = "${var.region}"
  }
}

resource "aws_route_table_association" "d4aws" {
  count = "${length(data.aws_availability_zones.d4aws.names)}"
  subnet_id = "${element(aws_subnet.d4aws.*.id, count.index)}"
  route_table_id = "${aws_route_table.d4aws.id}"
}
