resource "aws_cloudformation_stack" "d4aws" {
  name = "d4aws-${var.environment}"
  template_body = file("${path.module}/d4aws.json")
  capabilities = [ "CAPABILITY_IAM" ]
  parameters = {
    KeyName = "${aws_key_pair.d4aws.key_name}"
    NodeNamePrefix = "d4aws-${var.environment}-swarm"
    EnableSystemPrune = lookup(var.profiles[var.size], "enable_system_prune")
    EnableCloudStorEfs = lookup(var.profiles[var.size], "enable_cloudstor_efs")
    EnableCloudWatchLogs = lookup(var.profiles[var.size], "enable_cloudwatch_logs")
    EnablePublicAccess = lookup(var.profiles[var.size], "enable_public_access")

    ManagerSize = lookup(var.profiles[var.size], "manager_count")
    ManagerInstanceType = lookup(var.profiles[var.size], "manager_instance_type")
    ManagerDiskType = lookup(var.profiles[var.size], "manager_disk_type")
    ManagerDiskSize = lookup(var.profiles[var.size], "manager_disk_size")

    ClusterSize = lookup(var.profiles[var.size], "worker_count")
    InstanceType = lookup(var.profiles[var.size], "worker_instance_type")
    WorkerDiskType = lookup(var.profiles[var.size], "worker_disk_type")
    WorkerDiskSize = lookup(var.profiles[var.size], "worker_disk_size")

    Vpc = "${aws_vpc.d4aws.id}"
    VpcCidr = "${aws_vpc.d4aws.cidr_block}"
    PubSubnetAz1 = "${aws_subnet.d4aws.0.id}"
    PubSubnetAz2 = "${aws_subnet.d4aws.1.id}"
    PubSubnetAz3 = "${aws_subnet.d4aws.2.id}"
  }
  tags = {
    Name = "d4aws"
    Environment = var.environment
    Region = var.region
  }
}
