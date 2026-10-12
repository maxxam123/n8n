locals {
  iam_groups = [
    "developers",
    "operations",
    "auditors"
  ]

  user_directory = {
    "alice.smith"   = ["developers", "operations"]
    "bob.jones"     = ["developers"]
    "charlie.brown" = ["auditors"]
  }
}
