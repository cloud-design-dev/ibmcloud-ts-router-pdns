output "vnic_id" {
  value = ibm_is_virtual_network_interface.compute.id
}

output "compute_instance_ip" {
  value = ibm_is_virtual_network_interface.compute.primary_ip.0.address
}