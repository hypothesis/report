output "security_map" {
  value = {
    "bastion"    = [aws_security_group.bastion.id]
    "management" = [aws_security_group.management.id]
    "postgres"   = [aws_security_group.postgres.id]
  }
  description = "Map of security group ids"
}

output "ssh_key_name" {
  value       = aws_key_pair.ec2_ssh_key.key_name
  description = "The name of the EC2 SSH key."
}
