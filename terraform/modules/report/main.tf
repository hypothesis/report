module "vpc" {
  source      = "./vpc"
  network_map = var.network_map
}

module "security" {
  source      = "./security"
  network_map = var.network_map
  vpc_id      = module.vpc.vpc_id
}

module "ec2" {
  source       = "./ec2"
  network_map  = module.vpc.vpc_map
  security_map = module.security.security_map

  depends_on = [module.vpc, module.security]
}

module "rds" {
  source       = "./rds"
  network_map  = module.vpc.vpc_map
  security_map = module.security.security_map
}
