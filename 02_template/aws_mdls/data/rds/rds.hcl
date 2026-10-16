terraform {
  source = "git@github.com//vTAG"
}

inputs = {
  engine               = "postgres"
  engine_version       = "16.3"
  family               = "postgres16" # DB parameter group
  major_engine_version = "16"         # DB option group

  # Storage configuration baseline
  allocated_storage     = 20
  max_allocated_storage = 100 # Enables storage auto-scaling
  storage_type          = "gp3"

  # Performance and Security Defaults
  storage_encrypted   = true
  publicly_accessible = false # Enforces network isolation
  port                = 5432

  # Monitoring and Operations Baseline
  performance_insights_enabled          = true
  performance_insights_retention_period = 7 # Days
  create_monitoring_role                = true
  monitoring_interval                   = 60 # Seconds
  monitoring_role_name                  = "rds-enhanced-monitoring-role"

  # Maintenance & Backup Configurations
  backup_retention_period = 7
  backup_window           = "03:00-06:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  # Safeguards
  skip_final_snapshot = false
  deletion_protection = true # Can be explicitly overridden for ephemeral environments

  tags = {
    InfrastructureLayer = "data-tier"
    ProvisionedBy       = "Terragrunt"
  }
}
