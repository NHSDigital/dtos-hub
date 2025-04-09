locals {
  appgw_config = {
    for region in keys(var.regions) : region => {

      frontend_port = {
        https = 443
      }

      frontend_ip_configuration = {
        private = {
          subnet_id                     = module.subnets_hub["${module.config[region].names.subnet}-app-gateway"].id
          private_ip_address            = cidrhost(module.subnets_hub["${module.config[region].names.subnet}-app-gateway"].address_prefixes[0], 225)
          private_ip_address_allocation = "Static"
        }
        public = {
          public_ip_address_id = module.application-gateway-pip[region].id
        }
      }

      backend_address_pool = {
        apim_gateway = {
          fqdns = ["gateway.${var.dns_zone_name_private}"]
        }
        parman_www_dev = {
          fqdns = ["dev-${module.config[region].names.location_code}-nextjs-frontend.azurewebsites.net"]
        }
      }

      probe = {
        apim_gateway = {
          interval                                  = 30
          path                                      = "/status-0123456789abcdef"
          pick_host_name_from_backend_http_settings = true
          port                                      = 443
          protocol                                  = "Https"
          timeout                                   = 120
          unhealthy_threshold                       = 8
          match = {
            status_code = ["200-399"] # not strictly needed, but this stops Terraform detecting a change every time
          }
        }
      }

      ssl_certificate = {
        private = {
          key_vault_secret_id = module.lets_encrypt_certificate.key_vault_certificates["wildcard_private-${region}"].versionless_secret_id
        }
        public = {
          key_vault_secret_id = module.lets_encrypt_certificate.key_vault_certificates["wildcard-${region}"].versionless_secret_id
        }
      }

      backend_http_settings = {
        apim_gateway = {
          cookie_based_affinity               = "Disabled"
          pick_host_name_from_backend_address = true # allows this backend_http_settings to be shared by multiple rules
          port                                = 443
          probe_key                           = "apim_gateway" # the probe however is gateway-specific (which is the most important APIM URL)
          protocol                            = "Https"
          request_timeout                     = 180
        }
        parman_www_dev = {
          cookie_based_affinity               = "Disabled"
          pick_host_name_from_backend_address = true # allows this backend_http_settings to be shared by multiple rules
          port                                = 443
          protocol                            = "Https"
          request_timeout                     = 180
        }
      }

      http_listener = {
        apim_gateway_public = {
          frontend_ip_configuration_key = "public"
          frontend_port_key             = "https"
          host_name                     = "api.${var.dns_zone_name_public}"
          protocol                      = "Https"
          require_sni                   = true
          ssl_certificate_key           = "public"
          firewall_policy_id            = var.WAF_POLICY_ID_APIM_GATEWAY
        }
        apim_gateway_private = {
          frontend_ip_configuration_key = "private"
          frontend_port_key             = "https"
          host_name                     = "api.${var.dns_zone_name_private}"
          protocol                      = "Https"
          require_sni                   = true
          ssl_certificate_key           = "private"
        }
        parman_www_dev_public = {
          frontend_ip_configuration_key = "public"
          frontend_port_key             = "https"
          host_name                     = "www-dev.${var.dns_zone_name_public}"
          protocol                      = "Https"
          require_sni                   = true
          ssl_certificate_key           = "public"
          firewall_policy_id            = var.WAF_POLICY_ID_PARMAN_WEB
        }
      }

      request_routing_rule = {
        apim_gateway_public = {
          backend_address_pool_key  = "apim_gateway"
          backend_http_settings_key = "apim_gateway"
          http_listener_key         = "apim_gateway_public"
          priority                  = 900
          rule_type                 = "Basic"
        }
        parman_www_dev_public = {
          backend_address_pool_key  = "parman_www_dev"
          backend_http_settings_key = "parman_www_dev"
          http_listener_key         = "parman_www_dev_public"
          priority                  = 950
          rule_type                 = "Basic"
        }
        apim_gateway_private = {
          backend_address_pool_key  = "apim_gateway"
          backend_http_settings_key = "apim_gateway"
          http_listener_key         = "apim_gateway_private"
          priority                  = 1000
          rule_type                 = "Basic"
        }
      }
    }
  }
}
# end locals


module "application-gateway-pip" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/public-ip"

  name                = "${module.config[each.key].names.public-ip-address}-app-gateway"
  resource_group_name = azurerm_resource_group.rg_hub[each.key].name
  location            = each.key
  allocation_method   = "Static"
  zones               = each.value.is_primary_region ? ["1", "2", "3"] : null
  sku                 = "Standard"

  tags = var.tags
}

module "application-gateway" {
  for_each = local.appgw_config

  source = "../../dtos-devops-templates/infrastructure/modules/application-gateway"

  location                  = each.key
  resource_group_name       = azurerm_resource_group.rg_hub[each.key].name
  autoscale_min             = 1
  autoscale_max             = 10
  backend_address_pool      = each.value.backend_address_pool
  backend_http_settings     = each.value.backend_http_settings
  frontend_ip_configuration = each.value.frontend_ip_configuration
  frontend_port             = each.value.frontend_port
  http_listener             = each.value.http_listener
  key_vault_id              = module.key_vault[each.key].key_vault_id
  names                     = module.config[each.key].names.application-gateway
  gateway_subnet            = module.subnets_hub["${module.config[each.key].names.subnet}-app-gateway"]
  probe                     = each.value.probe
  request_routing_rule      = each.value.request_routing_rule
  sku                       = "WAF_v2"
  ssl_certificate           = each.value.ssl_certificate
  zones                     = var.regions[each.key].is_primary_region ? ["1", "2", "3"] : null

  tags = var.tags
}
