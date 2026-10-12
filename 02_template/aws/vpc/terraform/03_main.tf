resource "aws_vpc" "networks" {
  for_each = local.vpc_directory

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.global_tags,
    {
      Name        = "${each.key}-vpc"
      Team        = each.value.team
      IsCritical  = tostring(each.value.critical)
    }
  )
}
