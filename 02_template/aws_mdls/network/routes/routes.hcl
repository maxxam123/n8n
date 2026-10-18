terraform {
  source = "${get_repo_root()}//infrastructure-modules/routes"
}

inputs = {
  corporate_supernet_cidr = "192.168.0.0/16"
  secure_target_cidr      = "10.10.50.0/24"

  global_tags = {
    ManagedBy          = "Terragrunt-IaC"
    ArchitectureLayer   = "Network-Transit-Edge"
    DataClassification = "Confidential"
  }
}
