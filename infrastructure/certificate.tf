module "lets_encrypt_certificate" {
  source = "../../dtos-devops-templates/infrastructure/modules/lets-encrypt-certificate"

  certificates                 = var.lets_encrypt_certificates
  dns_zone_name                = var.dns_zone_name
  dns_zone_resource_group_name = var.dns_zone_resource_group_name
  environment                  = var.environment
  email                        = var.LETS_ENCRYPT_CONTACT_EMAIL
  key_vaults                   = module.key_vault
  storage_account_name_hub     = var.HUB_BACKEND_AZURE_STORAGE_ACCOUNT_NAME
  subscription_id_hub          = var.TARGET_SUBSCRIPTION_ID
  subscription_id_target       = var.TARGET_SUBSCRIPTION_ID
}
