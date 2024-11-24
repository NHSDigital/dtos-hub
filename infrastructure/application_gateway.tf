locals {
  frontend_port = {
    https = 443
  }

  frontend_ip_configuration = {
    private = {
      subnet_id                     = var.gateway_subnet.id
      private_ip_address            = cidrhost(var.gateway_subnet.address_prefixes[0], 225)
      private_ip_address_allocation = "Static"
    }
    public = {
      public_ip_address_id = var.public_ip_address_id
    }
  }

  backend_address_pool = {
    apim_gateway = {
      fqdns = [module.apim-private-dns-a-records["${each.key}-gateway"].fqdn]
    }
    apim_portal = {
      fqdns = [module.apim-private-dns-a-records["${each.key}-development"].fqdn]
    }
  }

  probe = {
    apim_gateway = {
      interval                                  = 30
      path                                      = "/status-0123456789abcdef"
      pick_host_name_from_backend_http_settings = true
      protocol                                  = "Https"
      timeout                                   = 120
      unhealthy_threshold                       = 8
    }
    apim_portal = {
      interval                                  = 60
      path                                      = "/signin"
      pick_host_name_from_backend_http_settings = true
      protocol                                  = "Https"
      timeout                                   = 300
      unhealthy_threshold                       = 8
    }
  }

  ssl_certificate = {
    private = {
      key_vault_secret_id = module.lets_encrypt_certificate.key_vault_certificates["wildcard_private-${each.key}"].versionless_secret_id
    }
    public = {
      key_vault_secret_id = module.lets_encrypt_certificate.key_vault_certificates["wildcard-${each.key}"].versionless_secret_id
    }
  }

  backend_http_settings = {
    apim_gateway = {
      cookieBasedAffinity                 = "Disabled"
      pick_host_name_from_backend_address = true
      port                                = 443
      probe_key                           = "apim_gateway"
      protocol                            = "Https"
      request_timeout                     = 180
    }
    apim_portal = {
      cookieBasedAffinity                 = "Disabled"
      pick_host_name_from_backend_address = true
      port                                = 443
      probe_key                           = "apim_portal"
      protocol                            = "Https"
      request_timeout                     = 180
    }
  }

  http_listener = {
    apim_portal_private = {
      frontend_ip_configuration_key = "private"
      frontend_port_key             = "https"
      hostname                      = "portal.${var.dns_zone_name_private}"
      protocol                      = "Https"
      require_sni                   = true
      ssl_certificate_key           = "private"
    }
    apim_gateway_private = {
      frontend_ip_configuration_key = "private"
      frontend_port_key             = "https"
      hostname                      = "api.${var.dns_zone_name_private}"
      protocol                      = "Https"
      require_sni                   = true
      ssl_certificate_key           = "private"
    }
    apim_gateway_public = {
      frontend_ip_configuration_key = "public"
      frontend_port_key             = "https"
      hostname                      = "api.${var.dns_zone_name_public}"
      protocol                      = "Https"
      require_sni                   = true
      ssl_certificate_key           = "public"
      # firewall_policy_id            =
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
    apim_gateway_private = {
      backend_address_pool_key  = "apim_gateway"
      backend_http_settings_key = "apim_gateway"
      http_listener_key         = "apim_gateway_private"
      priority                  = 1000
      rule_type                 = "Basic"
    }
    apim_portal_private = {
      backend_address_pool_key  = "apim_portal"
      backend_http_settings_key = "apim_portal"
      http_listener_key         = "apim_portal_private"
      priority                  = 1100
      rule_type                 = "Basic"
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
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/application-gateway"

  location                  = each.key
  resource_group_name       = azurerm_resource_group.rg_hub[each.key].name
  autoscale_min             = 1
  autoscale_max             = 10
  backend_address_pool      = local.backend_address_pool
  backend_http_settings     = local.backend_http_settings
  frontend_ip_configuration = local.frontend_ip_configuration
  frontend_port             = local.frontend_port
  http_listener             = local.http_listener
  key_vault_id              = module.key_vault[each.key].key_vault_id
  names                     = module.config[each.key].names.application-gateway
  gateway_subnet            = module.subnets_hub["${module.config[each.key].names.subnet}-app-gateway"]
  probe                     = local.probe
  public_ip_address_id      = module.application-gateway-pip[each.key].id
  request_routing_rule      = local.request_routing_rule
  sku                       = "WAF_v2"
  ssl_certificate           = local.ssl_certificate
  zones                     = each.value.is_primary_region ? ["1", "2", "3"] : null

  tags = var.tags
}
