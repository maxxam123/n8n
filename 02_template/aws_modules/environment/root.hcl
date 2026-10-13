generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region = "ap-south-1"
}
EOF
}

remote_state {
  backend = "s3"
  config =  {
    bucket = "test-bucket-dunhuang-test"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "my-lock-table"
  }
}
