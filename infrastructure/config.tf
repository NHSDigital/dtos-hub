module "config" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/shared-config?ref=892f57534a22ec9b17046856c0bd28cfa3c90389"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
