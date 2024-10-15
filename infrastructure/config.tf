module "config" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/shared-config?ref=32df88c630d01cda9395a3433315bf47dc6ed122"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
