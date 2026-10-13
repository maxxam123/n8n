variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "subnet_cidr" {
  default = "10.20.0.0/24"
}

variable "vpc_tags" {
  type = map(string)
  default = {}
}

variable "subnet_tags" {
  type = map(string)
  default = {}
}
