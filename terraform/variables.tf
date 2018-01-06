variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "size" {
  type = "string"
  default = "small"
}

variable "whitelist" {
  type = "list"
  default = [ "0.0.0.0/0" ]
}
