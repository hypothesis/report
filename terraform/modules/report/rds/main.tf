locals {
  subnet_ids = [
    for subnet, hash in var.network_map :
    !hash["public"] ? hash["id"] : ""
  ]

  vpc_security_group_ids = var.security_map["postgres"]

}
resource "aws_db_instance" "report" {
  allocated_storage                   = 20
  max_allocated_storage               = 200
  storage_encrypted                   = true
  db_subnet_group_name                = aws_db_subnet_group.report.id
  vpc_security_group_ids              = local.vpc_security_group_ids
  multi_az                            = true
  iam_database_authentication_enabled = true
  storage_type                        = "gp2"
  engine                              = "postgres"
  engine_version                      = "11.16"
  instance_class                      = "db.t3.small"
  identifier                          = "report-prod"
  username                            = "hopadmin"
  password                            = "changeme"
  db_name                             = "report"
}

resource "aws_db_subnet_group" "report" {
  name        = "report-prod"
  description = "Managed by Terraform"
  subnet_ids  = local.subnet_ids
}
