include "root" {
  path = find_in_parent_folders("root.hcl") # Adjust name if your root file is called terragrunt.hcl
}

terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//networking/route53?ref=v1.8.0"
}

inputs = {
  # Force us-east-1 since Route 53 is a global API endpoint
  aws_region = "us-east-1"

  zones = {
    "mycompany.com" = {
      comment = "Primary public corporate domain zone"
      tags = {
        Environment = "production"
      }
    }
    "://mycompany.com" = {
      comment = "Development environment public domain zone"
      tags = {
        Environment = "development"
      }
    }
  }

  tags = {
    Environment = "global"
    Component   = "dns-route53"
    ManagedBy   = "terragrunt"
  }
}
