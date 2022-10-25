output "ec2_ip_info" {
  value = {
    for k, v in var.network_map :
    k => {
      "private_ip"    = aws_instance.linux[k]["private_ip"]
      "public_ip"     = aws_instance.linux[k]["public_ip"]
      "instance_type" = aws_instance.linux[k]["instance_type"]
    }
  }
}

output "ec2_map" {
  value = local.ec2_map
}
