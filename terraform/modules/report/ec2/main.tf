locals {
  ec2_map = {
    for k, v in var.network_map :
    k => {
      git_branch                  = "terraform"
      ami                         = v["ami"]
      ssh_pub_key                 = v["ssh_pub_key"]
      key_name                    = v["ssh_pub_key_name"]
      instance_type               = v["instance_type"]
      subnet_id                   = v["id"]
      region                      = v["region"]
      associate_public_ip_address = v["public"]
      iam_instance_profile        = v["public"] ? "bastion" : "management"
      vpc_security_group_ids      = v["public"] ? var.security_map["bastion"] : var.security_map["management"]
      display_name                = v["public"] ? "${v["subnet_name"]}_bastion" : "${v["subnet_name"]}_management"
      hostname                    = v["public"] ? "bastion-${v["suffix"]}" : "mgmt-${v["suffix"]}"
    }
  }
}


resource "aws_instance" "linux" {
  for_each = local.ec2_map

  ami                         = each.value["ami"]
  associate_public_ip_address = each.value["associate_public_ip_address"]
  instance_type               = each.value["instance_type"]
  iam_instance_profile        = each.value["iam_instance_profile"]
  subnet_id                   = each.value["subnet_id"]
  vpc_security_group_ids      = each.value["vpc_security_group_ids"]
  key_name                    = each.value["key_name"]

  user_data = templatefile("${path.module}/scripts/userdata.cfg",
    {
      hostname    = each.value["hostname"]
      ssh_pub_key = each.value["ssh_pub_key"]
      region      = each.value["region"]
      git_branch  = each.value["git_branch"]
  })

  tags = {
    Name = each.value["display_name"]
  }
}
