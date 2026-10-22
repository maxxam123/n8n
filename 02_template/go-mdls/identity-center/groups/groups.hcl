# _envcommon/identity-center-groups.hcl

locals {
  source_base_url = "git::git@github.com:your-org/terraform-modules.git//identity-center-groups"
}

terraform {
  source = "${local.source_base_url}?ref=v1.3.0"
}

inputs = {
  groups = [
    "AWS-Platform-Engineering",
    "AWS-Security-Operations",
    "AWS-Auditors"
  ]
}# _envcommon/identity-center-groups.hcl

locals {
  source_base_url = "git::git@github.com:your-org/terraform-modules.git//identity-center-groups"
}

terraform {
  source = "${local.source_base_url}?ref=v1.3.0"
}

inputs = {
  groups = [
    "AWS-Platform-Engineering",
    "AWS-Security-Operations",
    "AWS-Auditors"
  ]
} 
