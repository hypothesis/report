module "report" {
  source      = "../../modules/report"
  network_map = var.network_map
  tags        = var.tags
}
