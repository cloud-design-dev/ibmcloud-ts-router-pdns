# output "compute_instance" {
#   value = ibm_is_instance.compute_instance
# }

output "compute_instance_ip" {
  value = ibm_is_virtual_network_interface.compute.primary_ip.0.address
}