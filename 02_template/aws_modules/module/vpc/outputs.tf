output "vpc_ids" {
  description = "A mapping map linking environment labels to their respective AWS VPC tracking IDs"
  value = {
    for name, vpc in aws_vpc.networks : name => vpc.id
  }
}

output "vpc_cidr_blocks" {
  description = "A map linking environment labels to their parsed network ranges"
  value = {
    for name, vpc in aws_vpc.networks : name => vpc.cidr_block
  }
}
