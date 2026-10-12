resource "aws_iam_group" "team_group" {
  name = "${local.team_name}-group"
}

resource "aws_iam_user" "team_users" {
  for_each = local.iam_users
  name = each.value # references the current username in the loop
}

resource "aws_iam_user_group_membership" "team_assignment" {
  for_each = local.iam_users
  user   = aws_iam_user.team_users[each.value].name
  groups = [aws_iam_group.team_group.name]
}
