include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com//maxxam123/modules-repo?version=vTAG"
}

inputs = {
  identifier = "dev-postgres-db"

  engine               = "postgres"
  engine_version       = "VER"
  family               = "postgres16" # DB parameter group
  major_engine_version = "16"         # DB option group
  instance_class       = "db.t4g.micro" # Cheap instance tier for dev

  allocated_storage     = MIN_STO
  max_allocated_storage = MAX_STO

  db_name  = "DB_NAME"
  username = "DB_USER"
  port     = 5432

  subnet_ids             = ["SUB_ONE", "SUB_TWO"]
  vpc_security_group_ids = ["SG_ID"]

  maintenance_window      = "MAIN_WIND" # Mon:00:00-Mon:03:00
  backup_window           = "BACK_WIND" # 03:00-06:00
  backup_retention_period = BACK_RET # 7

  deletion_protection = false
  skip_final_snapshot = true
}
