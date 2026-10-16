include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit corporate safety parameters and module source from _envcommon
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/data/rds.hcl"
}

# 3. Pull network dependencies dynamically from the active VPC layer
dependency "vpc" {
  config_path = "../../../network/VPC_NAME"
}

# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT OVERRIDES
# Terragrunt automatically merges these inputs on top of the defaults declared in _envcommon.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  identifier = "staging-application-db"

  # Sizing parameters for staging
  instance_class = "db.t4g.medium"
  multi_az       = false # Override to 'true' in your production/terragrunt.hcl configuration

  # Credentials setup
  db_name  = "app_staging_db"
  username = "cloud_admin"
  # Note: Leave 'password' empty if managing via AWS Secrets Manager or letting RDS generate one
  manage_master_user_password = true 

  # Network bindings computed instantly from state outputs
  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [dependency.vpc.outputs.default_security_group_id]

  # Override deletion protection for non-prod lifecycles to save costs during testing teardowns
  deletion_protection = false

  tags = {
    Environment = "staging"
  }
}
