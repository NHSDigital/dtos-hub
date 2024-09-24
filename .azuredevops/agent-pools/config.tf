module "config" {
  for_each = var.regions

  # Source location updated to use the git:: prefix to avoid URL encoding issues - note // between the URL and the path is required
  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/shared-config?ref=2fa836b230acff25c8626697fdf0e23cb598ca39"

  location    = each.key
  application = "hub"
  env         = var.environment
  tags        = var.tags
}
