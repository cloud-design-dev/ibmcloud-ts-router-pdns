output "vpc_id" {
  value = ibm_is_vpc.demo.id
}

output "vpc_crn" {
  value = ibm_is_vpc.demo.crn
}

output "vpc_default_security_group" {
  value = ibm_is_vpc.demo.default_security_group
}

output "services_security_group" {
  value = module.services_security_group.security_group_id
}

output "dmz_subnet_id" {
  value = ibm_is_subnet.dmz_zone_1.id
}

output "zone1_subnet_id" {
  value = ibm_is_subnet.services_zone_1.id
}

output "zone2_subnet_id" {
  value = ibm_is_subnet.services_zone_2.id
}

output "dmz_subnet_crn" {
  value = ibm_is_subnet.dmz_zone_1.crn
}

output "zone1_subnet_crn" {
  value = ibm_is_subnet.services_zone_1.crn
}

output "zone2_subnet_crn" {
  value = ibm_is_subnet.services_zone_2.crn
}

output "dmz_subnet_cidr" {
  value = ibm_is_subnet.dmz_zone_1.ipv4_cidr_block
}

output "zone1_subnet_cidr" {
  value = ibm_is_subnet.services_zone_1.ipv4_cidr_block
}

output "zone2_subnet_cidr" {
  value = ibm_is_subnet.services_zone_2.ipv4_cidr_block
}

