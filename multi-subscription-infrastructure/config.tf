module "config" {
  for_each = var.regions

  source = "../../dtos-devops-templates/infrastructure/modules/shared-config"

  location    = each.key
  application = var.application
  env         = var.environment
  env_type    = var.env_type
  tags        = var.tags
}
