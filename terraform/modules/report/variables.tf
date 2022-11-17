variable "network_map" {
  type        = map(any)
  description = "A map containing network details"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be applied to all resources provisioned"
}
