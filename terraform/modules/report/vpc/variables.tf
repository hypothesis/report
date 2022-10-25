variable "env_map" {
  type = map(any)
  default = {
    region    = "ca-central-1"
    cidr      = "10.10.0.0/16"
    name      = "report"
    linux_ami = "ami-095509bf36d02a8e0"
  }
}


variable "network_map" {
  type = map(any)
  default = {
    subnet_one = {
      az     = "cac1-az1"
      cidr   = "10.10.1.0/24"
      public = true
      suffix = "sn1"
    }
    subnet_two = {
      az     = "cac1-az2"
      cidr   = "10.10.2.0/24"
      public = true
      suffix = "sn2"
    }
    subnet_three = {
      az     = "cac1-az1"
      nat    = "subnet_one"
      cidr   = "10.10.3.0/24"
      public = false
      suffix = "sn3"
    }
    subnet_four = {
      az     = "cac1-az2"
      nat    = "subnet_two"
      cidr   = "10.10.4.0/24"
      public = false
      suffix = "sn4"
    }
  }
}
