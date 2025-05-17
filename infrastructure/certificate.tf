resource "acme_registration" "reg" {
  email_address = var.LETS_ENCRYPT_CONTACT_EMAIL
}

module "acme_certificate" {
  for_each = var.acme_certificates

  source = "../../dtos-devops-templates/infrastructure/modules/acme-certificate"

  providers = {
    azurerm             = azurerm
    azurerm.dns_public  = azurerm
    azurerm.dns_private = azurerm
  }

  acme_registration_account_key_pem   = acme_registration.reg.account_key_pem
  certificate_naming_key              = each.key
  certificate                         = each.value
  key_vaults                          = module.key_vault
  private_dns_zones                   = azurerm_resource_group.private_dns_rg
  public_dns_zone_resource_group_name = var.dns_zone_rg_name_public
  subscription_id_dns_public          = var.TARGET_SUBSCRIPTION_ID
}

output "certificates" {
  value     = module.acme_certificate
  sensitive = true
}
