locals {
  subnet_map           = var.network_map["vpc"]["subnets"]
  resource_name_prefix = var.network_map["vpc"]["env"]["defaults"]["name"]
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.network_map["vpc"]["env"]["defaults"]["cidr"]
  enable_dns_hostnames = true

  tags = {
    Name = local.resource_name_prefix
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.resource_name_prefix}_ig"
  }
}

resource "aws_eip" "eips" {
  for_each = {
    for key, value in local.subnet_map : key => value if value.public
  }

  depends_on = [aws_internet_gateway.internet_gateway]
  vpc        = true

  tags = {
    Name = "${local.resource_name_prefix}_${each.value["suffix"]}"
  }
}

resource "aws_subnet" "subnets" {
  for_each = local.subnet_map

  availability_zone_id = each.value["availability_zone_id"]
  cidr_block           = each.value["cidr_block"]
  vpc_id               = aws_vpc.vpc.id

  tags = {
    Name = "${local.resource_name_prefix}_${each.value["suffix"]}"
  }
}

resource "aws_nat_gateway" "nat_gateways" {
  for_each = {
    for key, value in local.subnet_map : key => value if value.public
  }

  allocation_id = aws_eip.eips[each.key].id
  subnet_id     = aws_subnet.subnets[each.key].id

  tags = {
    Name = "${local.resource_name_prefix}_${each.value["suffix"]}_ng"
  }
}

resource "aws_route_table" "route_tables" {
  for_each = local.subnet_map

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.resource_name_prefix}_${each.value["suffix"]}_rt"
  }
}

resource "aws_route_table_association" "route_table_associations" {
  for_each = local.subnet_map

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.key].id
}

resource "aws_route" "default_public_routes" {
  for_each = {
    for key, value in local.subnet_map : key => value if value.public
  }

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route_tables[each.key].id
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route" "default_private_routes" {
  for_each = {
    for key, value in local.subnet_map : key => value if !value.public
  }

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route_tables[each.key].id
  nat_gateway_id         = aws_nat_gateway.nat_gateways[each.value["nat"]].id
}

resource "aws_vpc_peering_connection" "us-prod" {
  peer_vpc_id = "vpc-bc4d91d9"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_peering_connection" "ca-prod" {
  peer_vpc_id = "vpc-09d7db76f771eba3f"
  vpc_id      = aws_vpc.vpc.id
  peer_region = "ca-central-1"
}

resource "aws_route" "us-prod" {
  for_each = {
    for key, value in local.subnet_map : key => value if !value.public
  }

  route_table_id            = aws_route_table.route_tables[each.key].id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.us-prod.id
}

resource "aws_route" "ca-prod" {
  for_each = {
    for key, value in local.subnet_map : key => value if !value.public
  }

  route_table_id            = aws_route_table.route_tables[each.key].id
  destination_cidr_block    = "10.100.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ca-prod.id
}
