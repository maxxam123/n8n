terraform {
  source = "git@github.com vTAG"
}

inputs = {
  trusted_arns = ["arn:aws:iam::123456789012:root"] 
}
