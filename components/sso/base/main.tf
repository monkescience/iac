resource "aws_ssoadmin_permission_set" "admin" {
  instance_arn     = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  name             = "admin"
  session_duration = "PT2H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

resource "aws_ssoadmin_account_assignment" "admin" {
  for_each = tomap({
    "monke-root" = "489721517942"
    "monke-dev"  = "387105013966"
    "monke-prod" = "978150176582"
  })

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.admin.group_id
}

resource "aws_identitystore_group" "admin" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_instance.identity_store_ids)[0]
  display_name      = "admin"
}

resource "aws_identitystore_group_membership" "vlutz" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_instance.identity_store_ids)[0]
  group_id          = aws_identitystore_group.admin.group_id
  member_id         = aws_identitystore_user.vlutz.user_id
}

resource "aws_identitystore_user" "vlutz" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_instance.identity_store_ids)[0]
  display_name      = "Valentin Lutz"
  user_name         = "vlutz"

  name {
    given_name  = "Valentin"
    family_name = "Lutz"
  }

  emails {
    primary = true
    value   = "allround.email@gmail.com"
  }
}