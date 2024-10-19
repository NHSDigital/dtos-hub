module "config" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/shared-config?ref=783b7d1e39b4f8e299fad5018396c7399742a0dc"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
