module "config" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/shared-config?ref=a97430c23c686fc16fa5cf387794c394aab01f54"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
