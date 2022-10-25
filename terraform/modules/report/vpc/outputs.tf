output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID VPC."
}

output "vpc_map" {
  value = {
    for k, v in var.network_map["vpc"]["subnets"] :
    k => {
      "availability_zone_id" = aws_subnet.subnets[k]["availability_zone_id"]
      "cidr_block"           = aws_subnet.subnets[k]["cidr_block"]
      "id"                   = aws_subnet.subnets[k]["id"]
      "ami"                  = var.network_map["vpc"]["env"]["defaults"]["ec2_ami"]
      "instance_type"        = var.network_map["vpc"]["env"]["defaults"]["ec2_instance_type"]
      "ssh_pub_key"          = var.network_map["vpc"]["env"]["defaults"]["ec2_ssh_pub_key"]
      "ssh_pub_key_name"     = "${local.resource_name_prefix}"
      "public"               = var.network_map["vpc"]["subnets"][k]["public"]
      "suffix"               = var.network_map["vpc"]["subnets"][k]["suffix"]
      "bastion"              = var.network_map["vpc"]["subnets"][k]["bastion"]
      "management"           = var.network_map["vpc"]["subnets"][k]["management"]
      "subnet_name"          = "${local.resource_name_prefix}_${var.network_map["vpc"]["subnets"][k]["suffix"]}"
      "region"               = var.network_map["vpc"]["env"]["defaults"]["region"]
    }
  }
  description = "A collection of useful VPC information."
}
