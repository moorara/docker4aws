provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

data "aws_availability_zones" "d4aws" {}

resource "aws_key_pair" "d4aws" {
  key_name = "d4aws-${var.environment}"
  public_key = file("${path.module}/d4aws-${var.environment}.pub")
}
