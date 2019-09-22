variable "vpc_cidrs" {
  type = object({
    ap-northeast-1 = string
    ap-northeast-2 = string
    ap-south-1     = string
    ap-southeast-1 = string
    ap-southeast-2 = string
    ca-central-1   = string
    eu-central-1   = string
    eu-north-1     = string
    eu-west-1      = string
    eu-west-2      = string
    eu-west-3      = string
    sa-east-1      = string
    us-east-1      = string
    us-east-2      = string
    us-west-1      = string
    us-west-2      = string
  })

  default = {
    ap-northeast-1 = "10.10.0.0/16",
    ap-northeast-2 = "10.11.0.0/16",
    ap-south-1     = "10.12.0.0/16",
    ap-southeast-1 = "10.13.0.0/16",
    ap-southeast-2 = "10.14.0.0/16",
    ca-central-1   = "10.15.0.0/16",
    eu-central-1   = "10.16.0.0/16",
    eu-north-1     = "10.17.0.0/16",
    eu-west-1      = "10.18.0.0/16",
    eu-west-2      = "10.19.0.0/16",
    eu-west-3      = "10.20.0.0/16",
    sa-east-1      = "10.21.0.0/16",
    us-east-1      = "10.22.0.0/16",
    us-east-2      = "10.23.0.0/16",
    us-west-1      = "10.24.0.0/16",
    us-west-2      = "10.25.0.0/16"
  }
}

variable "profiles" {
  type = map(object({
    tunnel_count           = number
    manager_count          = number
    manager_instance_type  = string
    manager_disk_type      = string
    manager_disk_size      = number
    worker_count           = number
    worker_instance_type   = string
    worker_disk_type       = string
    worker_disk_size       = number
    enable_system_prune    = string
    enable_cloudstor_efs   = string
    enable_cloudwatch_logs = string
    enable_public_access   = string
  }))

  default = {
    small = {
      tunnel_count           = 1
      manager_count          = 1
      manager_instance_type  = "t2.micro"
      manager_disk_type      = "gp2"
      manager_disk_size      = 20
      worker_count           = 2
      worker_instance_type   = "t2.micro"
      worker_disk_type       = "gp2"
      worker_disk_size       = 20
      enable_system_prune    = "yes"
      enable_cloudstor_efs   = "yes"
      enable_cloudwatch_logs = "yes"
      enable_public_access   = "yes"
    }

    medium = {
      tunnel_count           = 1
      manager_count          = 3
      manager_instance_type  = "t2.micro"
      manager_disk_type      = "gp2"
      manager_disk_size      = 50
      worker_count           = 5
      worker_instance_type   = "t2.micro"
      worker_disk_type       = "gp2"
      worker_disk_size       = 50
      enable_system_prune    = "yes"
      enable_cloudstor_efs   = "yes"
      enable_cloudwatch_logs = "yes"
      enable_public_access   = "yes"
    }

    large = {
      tunnel_count           = 1
      manager_count          = 5
      manager_instance_type  = "t2.micro"
      manager_disk_type      = "gp2"
      manager_disk_size      = 100
      worker_count           = 7
      worker_instance_type   = "t2.micro"
      worker_disk_type       = "gp2"
      worker_disk_size       = 100
      enable_system_prune    = "yes"
      enable_cloudstor_efs   = "yes"
      enable_cloudwatch_logs = "yes"
      enable_public_access   = "yes"
    }
  }
}
