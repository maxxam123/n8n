resource "aws_vpc" "networks" {
  for_each = var.vpc_directory

  # Loops through and maps attributes to their respective VPC blocks
  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.global_tags,
    {
      Name        = "${each.key}-vpc" # Creates production-vpc, staging-vpc, etc.
      Team        = each.value.team
      IsCritical  = tostring(each.value.critical)
    }
  )
}
