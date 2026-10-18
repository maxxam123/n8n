remote_state {
  backend = "s3"
  generate = {
    path = "state.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    profile = "max"
    role_arn = "arn:aws:iam::53452345245:role/terraform"
    bucket = "maxxam123-terrafrom-state"

    key = "${path_relative_to_include()}/terraform.tfstat"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-lock-table"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrung"

  contents = <<EOF
provider "aws" {
  region = "us-east-1" # region = "${contains(split("/", get_terragrunt_dir()), "waf-global") ? "us-east-1" : "eu-west-1"}"
  profile = "max"

  assume_role {
    session_name = "test-01"
    role_arn = "arn:aws:iam::5204701374013:role/terraform"
  }
}
EOF
}
