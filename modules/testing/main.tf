resource "ibm_is_floating_ip" "demo" {
  name           = "${var.prefix}-floating-ip"
  zone           = var.zone
  resource_group = var.resource_group_id
  tags           = var.tags
}

resource "ibm_is_virtual_network_interface_floating_ip" "vni_fip" {
  virtual_network_interface = var.vnic_id
  floating_ip               = ibm_is_floating_ip.demo.id
}

# module "add_rules_to_default_vpc_security_group" {
#   source                       = "terraform-ibm-modules/security-group/ibm"
#   version                      = "2.6.2"
#   add_ibm_cloud_internal_rules = true
#   use_existing_security_group  = true
#   existing_security_group_name = "${var.prefix}-default-sg"
#   security_group_rules = [
#     {
#       name      = "allow-home-ssh-inbound"
#       direction = "inbound"
#       remote    = var.home_ip
#       tcp = {
#         port_min = 22
#         port_max = 22
#       }
#     }
#   ]
#   tags = var.tags
# }