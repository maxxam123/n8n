variable "vpc_directory" {
  type = map(object({
    cidr_block = string
    team       = string
    critical   = bool
  }))
}

resource "aws_vpc" "networks" {
  for_each = var.vpc_directory

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name       = "${each.key}-vpc"
    Team       = each.value.team
    IsCritical = tostring(each.value.critical)
  }
}
