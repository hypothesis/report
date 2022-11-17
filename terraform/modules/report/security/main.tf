resource "aws_security_group" "bastion" {
  name        = "${var.network_map["vpc"]["env"]["defaults"]["name"]}-bastion"
  description = "Bastion security group for ${var.network_map["vpc"]["env"]["defaults"]["name"]}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Enable ssh from everywhere."
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Enable outbound access to everwhere using all protocols."
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "management" {
  name        = "${var.network_map["vpc"]["env"]["defaults"]["name"]}-management"
  description = "Management security group for ${var.network_map["vpc"]["env"]["defaults"]["name"]}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Enable ssh from bastion."
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Enable outbound access to everwhere using all protocols."
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "postgres" {
  name        = "${var.network_map["vpc"]["env"]["defaults"]["name"]}-postgres"
  description = "Postgres security group for ${var.network_map["vpc"]["env"]["defaults"]["name"]}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Enable 5432 from management."
    from_port   = "5432"
    to_port     = "5432"
    protocol    = "tcp"
    security_groups = [
      aws_security_group.management.id,
      aws_security_group.report.id
    ]
  }
}

resource "aws_security_group" "report" {
  name        = "${var.network_map["vpc"]["env"]["defaults"]["name"]}-app"
  description = "Used by the global reporting application"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Enable ssh from management."
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [aws_security_group.management.id]
  }

  egress {
    description = "Enable outbound access to everwhere using all protocols."
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ec2_ssh_key" {
  key_name   = var.network_map["vpc"]["env"]["defaults"]["name"]
  public_key = var.network_map["vpc"]["env"]["defaults"]["ec2_ssh_pub_key"]
}
