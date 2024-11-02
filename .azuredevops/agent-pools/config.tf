module "config" {
  for_each = var.regions

  source = "../../../dtos-devops-templates/infrastructure/modules/shared-config"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
