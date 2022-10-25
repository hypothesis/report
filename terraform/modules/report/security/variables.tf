variable "vpc_id" {
  description = "The AWS vpc_id"
  type        = string
}

variable "network_map" {
  type = map(any)
  default = {
    region      = "ca-central-1"
    cidr        = "10.10.0.0/16"
    environment = "report"
  }
}
