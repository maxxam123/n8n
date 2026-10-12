resource "aws_iam_group" "groups" {
  for_each = toset(local.iam_groups)
  name     = each.value
}

resource "aws_iam_user" "users" {
  for_each = local.user_directory
  name     = each.key
  path     = "/company/"
}

resource "aws_iam_user_group_membership" "assignments" {
  for_each = local.user_directory
  user   = aws_iam_user.users[each.key].name
  groups = each.value

  depends_on = [aws_iam_group.groups]
}
