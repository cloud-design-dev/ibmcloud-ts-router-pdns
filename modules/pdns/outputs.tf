output "customer_resolver_ips" {
  value = ibm_dns_custom_resolver.demo.locations[*].dns_server_ip
}