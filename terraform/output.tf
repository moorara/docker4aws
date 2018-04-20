output "managers" {
  value = "${lookup(var.config, "${var.size}.manager.count")}"
}

output "workers" {
  value = "${lookup(var.config, "${var.size}.worker.count")}"
}

output "whitelist" {
  value = "${var.whitelist}"
}

output "vpc_cidr" {
  value = "${aws_vpc.d4aws.cidr_block}"
}

output "subnet_cidr" {
  value = ["${aws_subnet.d4aws.*.cidr_block}"]
}

output "subnet_zone" {
  value = ["${join(", ", aws_subnet.d4aws.*.availability_zone)}"]
}

output "cloudformation" {
  value = ["${aws_cloudformation_stack.d4aws.*.outputs}"]
}
