output "subnet_map" {
  value = module.vpc.vpc_map
}

output "ec2_map" {
  value = module.ec2.ec2_map
}

output "rds_address" {
  value = module.rds.address
}
