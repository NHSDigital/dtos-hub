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

resource "random_password" "pfx" {
  for_each = var.acme_certificates

  length  = 30
  special = true
}

resource "acme_certificate" "hub" {
  for_each = var.acme_certificates

  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = each.value.common_name
  subject_alternative_names = each.value.subject_alternative_names
  key_type                  = each.value.key_type
  certificate_p12_password  = random_password.pfx[each.key].result

  dns_challenge {
    provider = "azuredns"
    config = {
      # https://go-acme.github.io/lego/dns/azuredns/
      # AZURE_AUTH_METHOD     = "cli"
      # AZURE_SUBSCRIPTION_ID = var.TARGET_SUBSCRIPTION_ID
      AZURE_RESOURCE_GROUP  = lookup(each.value, "zone_rg_name", var.dns_zone_rg_name_public)
      AZURE_ZONE_NAME       = each.value.zone_name
    }
  }
}

locals {
  # There are multiple certs, and possibly multiple regional Key Vaults to store them in.
  # We cannot nest for loops inside a map, so first iterate all permutations as a list of objects...
  acme_certs_object_list = flatten([
    for cert_key, cert_values in var.acme_certificates : [
      for region in keys(module.key_vault) : merge(
        {
          cert_key    = cert_key # 1st iterator
          region      = region   # 2nd iterator
        },
        cert_values
      )
    ]
  ])
  # ...then project them into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  acme_certs_map = {
    for item in local.acme_certs_object_list : "${item.cert_key}-${item.region}" => item
  }
}

resource "azurerm_key_vault_certificate" "acme" {
  for_each = acme_certs_map

  name         = replace(replace(each.value.common_name, "*.", "wildcard-"), ".", "-")
  key_vault_id = module.key_vault[each.value.region].key_vault_id

  certificate {
    contents = acme_certificate.hub[each.value.cert_key].certificate_p12
    password = random_password.pfx[each.value.cert_key].result
  }

  tags = {
    managed_by = "terraform"
  }
}

# Workaround while App Service cannot import elliptic curve Key Vault Certificate objects
resource "azurerm_key_vault_secret" "acme" {
  for_each = acme_certs_map

  name         = "pfx-${replace(replace(each.value.common_name, "*.", "wildcard-"), ".", "-")}"
  key_vault_id = module.key_vault[each.value.region].key_vault_id
  value        = acme_certificate.hub[each.value.cert_key].certificate_p12
  content_type = "application/x-pkcs12"

  tags = {
    managed_by = "terraform"
  }
}
