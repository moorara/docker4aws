output "managers" {
  value = lookup(var.profiles[var.size], "manager_count")
}

output "workers" {
  value = lookup(var.profiles[var.size], "worker_count")
}

output "whitelist" {
  value = var.whitelist
}

output "vpc_cidr" {
  value = "${aws_vpc.d4aws.cidr_block}"
}

output "subnet_cidr" {
  value = [ "${aws_subnet.d4aws.*.cidr_block}" ]
}

output "subnet_zone" {
  value = [ "${join(", ", aws_subnet.d4aws.*.availability_zone)}" ]
}

output "cloudformation" {
  value = [ "${aws_cloudformation_stack.d4aws.*.outputs}" ]
}
