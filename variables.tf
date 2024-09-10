variable "ibmcloud_api_key" {
  description = "The IBM Cloud API key to use for provisioning resources"
  type        = string
  sensitive   = true
}

variable "tailscale_api_key" {
  description = "The Tailscale API key"
  type        = string
  sensitive   = true
}

variable "tailscale_tailnet_id" {
  description = "The Tailscale tailnet ID"
  type        = string
}

variable "project_prefix" {
  description = "The prefix to use for naming resources. If none is provided, a random string will be generated."
  type        = string
  default     = ""
}

variable "ibmcloud_region" {
  description = "The IBM Cloud region to use for provisioning VPCs and other resources."
  type        = string
}

variable "existing_resource_group" {
  description = "The IBM Cloud resource group to assign to the provisioned resources."
  type        = string
}

variable "existing_ssh_key" {
  description = "The name of an existing SSH key to use for provisioning resources. If one is not provided, a new key will be generated."
  type        = string
  default     = ""
}

variable "hub_prefix" {
  description = "The address prefix to use for the hub VPC"
  type        = string
  default     = "192.168.0.0/18"
}

variable "prod_prefix" {
  description = "The address prefix to use for the prod_vpc VPC"
  type        = string
  default     = "10.250.0.0/18"
}

variable "dev_prefix" {
  description = "The address prefix to use for the dev_vpc VPC"
  type        = string
  default     = "172.16.64.0/18"
}
