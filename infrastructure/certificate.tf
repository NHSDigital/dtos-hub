module "lets_encrypt_certificate" {
  source = "../../dtos-devops-templates/infrastructure/modules/lets-encrypt-certificates"

  certificates                 = var.lets_encrypt_certificates
  dns_zone_names               = var.dns_zone_name_public
  dns_zone_resource_group_name = var.dns_zone_rg_name_public
  environment                  = var.environment
  email                        = var.LETS_ENCRYPT_CONTACT_EMAIL
  key_vaults                   = module.key_vault
  storage_account_name_hub     = var.HUB_BACKEND_AZURE_STORAGE_ACCOUNT_NAME
  subscription_id_hub          = var.TARGET_SUBSCRIPTION_ID
  subscription_id_target       = var.TARGET_SUBSCRIPTION_ID
}

resource "acme_registration" "reg" {
  email_address = "nobody554365765@nhs.net"
}

resource "acme_certificate" "certificate1" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "www-test-1.non-live.nationalscreening.nhs.uk"
  # subject_alternative_names = ["www2.example.com"]
  key_type                  = "P256"

  dns_challenge {
    provider = "azuredns"
    config = {
      AZURE_AUTH_METHOD     = "cli"
      AZURE_RESOURCE_GROUP  = var.dns_zone_rg_name_public
      AZURE_ZONE_NAME       = "non-live.nationalscreening.nhs.uk"
      AZURE_SUBSCRIPTION_ID = var.TARGET_SUBSCRIPTION_ID
    }
  }
}

resource "azurerm_key_vault_certificate" "acme_imported_cert" {
  name         = "acme-test-cert"
  key_vault_id = module.key_vault["uksouth"].key_vault_id

  certificate {
    contents = acme_certificate.certificate1.certificate_p12
    password = "" # Blank password
  }
}
