variable "vpc_cidrs" {
  type = "map"
  default = {
    ap-northeast-1  =  "10.10.0.0/16",
    ap-northeast-2  =  "10.11.0.0/16",
    ap-south-1      =  "10.12.0.0/16",
    ap-southeast-1  =  "10.13.0.0/16",
    ap-southeast-2  =  "10.14.0.0/16",
    ca-central-1    =  "10.15.0.0/16",
    cn-north-1      =  "10.16.0.0/16"
    eu-central-1    =  "10.17.0.0/16",
    eu-west-1       =  "10.18.0.0/16",
    eu-west-2       =  "10.19.0.0/16",
    eu-west-3       =  "10.20.0.0/16",
    sa-east-1       =  "10.21.0.0/16",
    us-east-1       =  "10.22.0.0/16",
    us-east-2       =  "10.23.0.0/16",
    us-west-1       =  "10.24.0.0/16",
    us-west-2       =  "10.25.0.0/16"
  }
}

variable "config" {
  type = "map"
  default = {
    small.tunnel.count             =  1
    small.manager.count            =  1
    small.worker.count             =  2
    small.manager.instance_type    =  "t2.micro"
    small.worker.instance_type     =  "t2.micro"
    small.manager.disk_type        =  "gp2"
    small.worker.disk_type         =  "gp2"
    small.manager.disk_size        =  20
    small.worker.disk_size         =  20
    small.enable_system_prune      =  "yes"
    small.enable_cloudstor_efs     =  "yes"
    small.enable_cloudwatch_logs   =  "yes"
    small.enable_public_access     =  "yes"

    medium.tunnel.count            =  1
    medium.manager.count           =  3
    medium.worker.count            =  5
    medium.manager.instance_type   =  "t2.micro"
    medium.worker.instance_type    =  "t2.micro"
    medium.manager.disk_type       =  "gp2"
    medium.worker.disk_type        =  "gp2"
    medium.manager.disk_size       =  50
    medium.worker.disk_size        =  50
    medium.enable_system_prune     =  "yes"
    medium.enable_cloudstor_efs    =  "yes"
    medium.enable_cloudwatch_logs  =  "yes"
    medium.enable_public_access    =  "yes"

    large.tunnel.count             =  1
    large.manager.count            =  5
    large.worker.count             =  7
    large.manager.instance_type    =  "t2.micro"
    large.worker.instance_type     =  "t2.micro"
    large.manager.disk_type        =  "gp2"
    large.worker.disk_type         =  "gp2"
    large.manager.disk_size        =  100
    large.worker.disk_size         =  100
    large.enable_system_prune      =  "yes"
    large.enable_cloudstor_efs     =  "yes"
    large.enable_cloudwatch_logs   =  "yes"
    large.enable_public_access     =  "yes"
  }
}
