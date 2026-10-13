
variable "vpc_directory" {
  description = "A structural map containing unique network environment boundaries"
  type = map(object({
    cidr_block = string
    team       = string
    critical   = bool
  }))
}

locals {
  # Global static configuration injected automatically across all looped elements
  global_tags = {
    ManagedBy = "Terragrunt-Loop-Engine"
  }
}
