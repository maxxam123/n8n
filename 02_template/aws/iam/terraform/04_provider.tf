provider "aws" {
  region = "eu-central-1"
}

terraform {

  backend "s3" {
    bucket = "BUCKET"
    key    = "global/REPO/terraform.tfstate"
    dynamodb_table = "terraform_state"
    region = "eu-central-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
