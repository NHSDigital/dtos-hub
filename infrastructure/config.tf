module "config" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/shared-config?ref=9f8fedc673c36f4c406b958579cde873edde5f66"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
