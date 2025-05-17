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
  email_address = "nobody55436765@nhs.net"
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
  certificate_name                    = each.key
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

# locals {
#   # There are multiple certs, and possibly multiple regional Key Vaults to store them in.
#   # We cannot nest for loops inside a map, so first iterate all permutations as a list of objects...
#   acme_certs_object_list = flatten([
#     for cert_key, cert_values in var.acme_certificates : [
#       for region in keys(module.key_vault) : merge(
#         {
#           naming_key           = cert_key # 1st iterator
#           region               = region   # 2nd iterator
#           name                 = replace(replace(cert_values.common_name, "*.", "wildcard-"), ".", "-")
#           pfx_blob_secret_name = "pfx-${replace(replace(cert_values.common_name, "*.", "wildcard-"), ".", "-")}"
#         },
#         cert_values
#       )
#     ]
#   ])
#   # ...then project them into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
#   acme_certs_map = {
#     for item in local.acme_certs_object_list : "${item.naming_key}-${item.region}" => item
#   }
# }

# resource "acme_registration" "reg" {
#   email_address = "nobody55436765@nhs.net"
# }

# resource "random_password" "pfx" {
#   for_each = var.acme_certificates

#   length  = 30
#   special = true
# }

# # Create CNAME records for any redirected DNS-01 challenges. Lego azuredns provider will validate these before allowing a redirected AZURE_ZONE_NAME.
# resource "azurerm_dns_cname_record" "challenge_redirect" {
#   for_each = { for k, v in var.acme_certificates : k => v if v.dns_cname_zone_name != null }

#   name                = "_acme-challenge.${replace(each.value.common_name, ".${each.value.dns_cname_zone_name}", "")}"
#   zone_name           = each.value.dns_cname_zone_name
#   resource_group_name = coalesce(each.value.dns_challenge_zone_rg_name, var.dns_zone_rg_name_public)
#   ttl                 = 300
#   record              = "_acme-challenge.${split(".", each.value.common_name)[0]}.${each.value.dns_challenge_zone_name}"
# }

# # Private DNS zones that overlap the public namespace also need the challenge CNAME records to pass Lego azuredns checks. Private DNS is regional.
# resource "azurerm_private_dns_cname_record" "challenge_redirect_private" {
#   for_each = { for k, v in local.acme_certs_map : k => v if v.dns_private_cname_zone_name != null }

#   name                = "_acme-challenge.${replace(each.value.common_name, ".${each.value.dns_private_cname_zone_name}", "")}"
#   zone_name           = each.value.dns_private_cname_zone_name
#   resource_group_name = azurerm_resource_group.private_dns_rg[each.value.region].name
#   ttl                 = 300
#   record              = azurerm_dns_cname_record.challenge_redirect[each.value.naming_key].record
# }

# resource "acme_certificate" "hub" {
#   for_each = var.acme_certificates

#   account_key_pem           = acme_registration.reg.account_key_pem
#   common_name               = each.value.common_name
#   subject_alternative_names = each.value.subject_alternative_names
#   key_type                  = each.value.key_type
#   certificate_p12_password  = random_password.pfx[each.key].result

#   dns_challenge {
#     provider = "azuredns"
#     config = { # https://go-acme.github.io/lego/dns/azuredns/
#       # AZURE_AUTH_METHOD     = "cli"
#       # AZURE_SUBSCRIPTION_ID = var.TARGET_SUBSCRIPTION_ID
#       AZURE_RESOURCE_GROUP = lookup(each.value, "zone_rg_name", var.dns_zone_rg_name_public)
#       AZURE_ZONE_NAME      = each.value.dns_challenge_zone_name
#     }
#   }

#   depends_on = [
#     azurerm_dns_cname_record.challenge_redirect,
#     azurerm_private_dns_cname_record.challenge_redirect_private
#   ]
# }

# resource "azurerm_key_vault_certificate" "acme" {
#   for_each = local.acme_certs_map

#   name         = each.value.name
#   key_vault_id = module.key_vault[each.value.region].key_vault_id

#   certificate {
#     contents = acme_certificate.hub[each.value.naming_key].certificate_p12
#     password = random_password.pfx[each.value.naming_key].result
#   }
# }

# # Workaround while App Service cannot import elliptic curve Key Vault Certificate objects
# resource "azurerm_key_vault_secret" "acme" {
#   for_each = local.acme_certs_map

#   name         = each.value.pfx_blob_secret_name
#   key_vault_id = module.key_vault[each.value.region].key_vault_id
#   value        = acme_certificate.hub[each.value.naming_key].certificate_p12
#   content_type = "application/x-pkcs12"
# }

# output "key_vault_certificates2" {
#   value = {
#     for k, v in local.acme_certs_map : k => {
#       name                  = v.name
#       naming_key            = v.naming_key
#       subject               = v.common_name
#       location              = v.region
#       pfx_blob_secret_name  = v.pfx_blob_secret_name
#       id                    = azurerm_key_vault_certificate.acme[k].id
#       versionless_id        = azurerm_key_vault_certificate.acme[k].versionless_id
#       versionless_secret_id = azurerm_key_vault_certificate.acme[k].versionless_secret_id
#     }
#   }
# }

# output "pfx_passwords" {
#   value     = { for k, v in random_password.pfx : k => v.result }
#   sensitive = true
# }
