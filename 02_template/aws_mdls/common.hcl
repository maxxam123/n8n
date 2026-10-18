# /common.hcl (Located at the repository root)
locals {
  # 1. Core Corporate Identification
  company_name   = "acme"
  company_domain = "acme-enterprise.com"

  # 2. Global Cloud Topology Standards
  # Primary and Secondary regions used globally for Disaster Recovery alignment
  primary_dr_region   = "us-east-1"
  secondary_dr_region = "us-west-2"

  # 3. Global Network CIDR Allocation Framework
  # Used to prevent overlap when provisioning corporate transit bridges or networks
  network_allocations = {
    core_transit_cidr = "10.0.0.0/16"
    dev_supernet      = "10.10.0.0/15"
    prod_supernet     = "10.20.0.0/15"
  }

  # 4. Global Baseline Tagging (Mandatory for all resources under the corporate umbrella)
  global_tags = {
    Organization = "Acme-Corp"
    InfrastructureSource = "https://github.com"
    Provisioner          = "Terragrunt"
  }

  # 5. Centralized Compliance, Security, & Golden Tooling Metadata
  # Keeps third-party agent versions, compliance levels, or AMI criteria standardized
  security_baselines = {
    supported_tls_policies = ["ELBSecurityPolicy-TLS13-1-2-2021-06"]
    crowdstrike_agent_version = "7.15.0"
    tenable_agent_version     = "10.6.2"
    pci_dss_compliance_required = true
  }
}
