output "ts_router_subnet_cidr" {
  value = module.lab_vpc.dmz_subnet_cidr
}

output "zone1_subnet_cidr" {
  value = module.lab_vpc.zone1_subnet_cidr
}

output "zone2_subnet_cidr" {
  value = module.lab_vpc.zone2_subnet_cidr
}

output "custom_resolver_ips" {
  value = module.pdns.customer_resolver_ips
}

output "lab_fqdns" {
  value = ["whoami.${local.prefix}-${var.private_dns_zone}", "tools.${local.prefix}-${var.private_dns_zone}", "requests.${local.prefix}-${var.private_dns_zone}", "dashboard.${local.prefix}-${var.private_dns_zone}"]
}

output "workload_instance_ip" {
  value = module.prod_compute.compute_instance_ip
}