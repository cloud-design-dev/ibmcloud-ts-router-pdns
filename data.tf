data "ibm_is_zones" "regional" {
  region = var.ibmcloud_region
}

data "ibm_is_ssh_key" "sshkey" {
  count = var.existing_ssh_key != "" ? 1 : 0
  name  = var.existing_ssh_key
}

# just used during testing when on laptop can can't start tailscale 
# remove when done
#data "ibm_is_vpc" "landing_zone" {
#  name = "ca-lz-vpc-rst"
#}
