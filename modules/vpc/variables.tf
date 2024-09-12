variable "prefix" {
  description = "Prefix to add to all deployed resources"
  type        = string
}

variable "ibmcloud_region" {
  description = "The region to create the VPC in"
  type        = string
}

variable "resource_group_id" {}
variable "tags" {}

variable "classic_access" {
  description = "Whether to enable classic access for the VPC"
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The default address prefix for the VPC"
  type        = string
  default     = "auto"
}
variable "home_ip" {}