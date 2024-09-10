variable "instance_profile" {
  description = "The name of the instance profile to use for the compute instances."
  type        = string
  default     = "cx2-2x4"
}

variable "base_image" {
  description = "The name of the base image to use for the compute instances."
  type        = string
  default     = "ibm-ubuntu-22-04-4-minimal-amd64-3"
}

variable "subnet_id" {}
variable "tags" {}
variable "name" {}
variable "resource_group_id" {}
variable "zone" {}
variable "vpc_id" {}
variable "ssh_key_ids" {}
variable "cloud_init" {}
variable "vpc_default_security_group" {}