output "dmz_subnet_cidr" {
  value = module.lab_vpc.dmz_subnet_cidr
}

output "zone1_subnet_cidr" {
  value = module.lab_vpc.zone1_subnet_cidr
}

output "zone2_subnet_cidr" {
  value = module.lab_vpc.zone2_subnet_cidr
}

output "customer_resolver_ips" {
  value = module.pdns.customer_resolver_ips
}

output "whoami_fqdn" {
  value = "whoami.${local.prefix}-demo.lab"
}