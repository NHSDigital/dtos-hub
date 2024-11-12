data "azuread_group" "avd_users" {
  display_name = var.avd_users_group_name
}

data "azuread_group" "avd_admins" {
  display_name = var.avd_admins_group_name
}
