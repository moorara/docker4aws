data "aws_ami" "debian" {
  most_recent = true
  owners = [ "379101102735" ]
  filter {
    name = "name"
    values = [ "debian-stretch-hvm-x86_64-gp2-*" ]
  }
  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }
}

resource "aws_security_group" "tunnel" {
  name = "d4aws-tunnel-${var.environment}"
  vpc_id = "${aws_vpc.d4aws.id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "${aws_vpc.d4aws.cidr_block}" ]
  }
  ingress {
    to_port = -1
    from_port = -1
    protocol = "icmp"
    cidr_blocks = [ "${aws_vpc.d4aws.cidr_block}" ]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "${aws_vpc.d4aws.cidr_block}" ]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.whitelist
  }
  tags = {
    Name = "d4aws"
    Environment = var.environment
    Region = var.region
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "tunnel" {
  name = "d4aws-tunnel-${var.environment}"
  image_id = "${data.aws_ami.debian.id}"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.tunnel.id}" ]
  associate_public_ip_address = true
  key_name = "${aws_key_pair.d4aws.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tunnel" {
  name = "d4aws-tunnel-${var.environment}"
  vpc_zone_identifier = "${aws_subnet.d4aws.*.id}"
  launch_configuration = "${aws_launch_configuration.tunnel.name}"
  min_size = lookup(var.profiles[var.size], "tunnel_count")
  desired_capacity = lookup(var.profiles[var.size], "tunnel_count")
  max_size = lookup(var.profiles[var.size], "tunnel_count")
  tag {
    key = "Name"
    value = "d4aws-tunnel"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = var.environment
    propagate_at_launch = true
  }
  tag {
    key = "Region"
    value = var.region
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
