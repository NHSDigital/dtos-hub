module "config" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/shared-config?ref=dfeb17455854c200eaafa58d3f0aea496db2d485"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
