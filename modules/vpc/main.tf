locals {

  zones = length(data.ibm_is_zones.regional.zones)
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.ibmcloud_region}-${zone + 1}"
    }
  }
}

resource "ibm_is_vpc" "demo" {
  name                        = "${var.prefix}-vpc"
  resource_group              = var.resource_group_id
  classic_access              = var.classic_access
  address_prefix_management   = var.default_address_prefix
  default_network_acl_name    = "${var.prefix}-default-acl"
  default_security_group_name = "${var.prefix}-default-sg"
  default_routing_table_name  = "${var.prefix}-default-rt"
  tags                        = var.tags
}

module "add_rules_to_default_vpc_security_group" {
  depends_on                   = [ibm_is_vpc.demo]
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "2.6.2"
  add_ibm_cloud_internal_rules = true
  use_existing_security_group  = true
  existing_security_group_name = "${var.prefix}-default-sg"
  security_group_rules = [
    {
      name      = "allow-ts-cidr-ssh-inbound"
      direction = "inbound"
      remote    = "100.64.0.0/10"
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name      = "allow-icmp-inbound"
      direction = "inbound"
      icmp = {
        type = 8
      }
      remote = "100.64.0.0/10"
    }
  ]
  tags = var.tags
}

resource "ibm_is_public_gateway" "demo" {
  count          = length(data.ibm_is_zones.regional.zones)
  name           = "${var.prefix}-pubgw-${count.index + 1}"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.demo.id
  zone           = local.vpc_zones[count.index].zone
  tags           = concat(var.tags, ["zone:${local.vpc_zones[count.index].zone}"])
}

resource "ibm_is_subnet" "dmz_zone_1" {
  name                     = "${var.prefix}-dmz-subnet-zone-1"
  resource_group           = var.resource_group_id
  vpc                      = ibm_is_vpc.demo.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "32"
  tags                     = concat(var.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_subnet" "services_zone_1" {
  name                     = "${var.prefix}-services-subnet-zone-1"
  resource_group           = var.resource_group_id
  vpc                      = ibm_is_vpc.demo.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "64"
  tags                     = concat(var.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_subnet" "services_zone_2" {
  name                     = "${var.prefix}-services-subnet-zone-2"
  resource_group           = var.resource_group_id
  vpc                      = ibm_is_vpc.demo.id
  zone                     = local.vpc_zones[1].zone
  total_ipv4_address_count = "64"
  tags                     = concat(var.tags, ["zone:${local.vpc_zones[1].zone}"])
}

module "services_security_group" {
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "2.6.2"
  vpc_id                       = ibm_is_vpc.demo.id
  add_ibm_cloud_internal_rules = true
  security_group_name          = "${var.prefix}-services-sg"
  security_group_rules = [{
    name      = "allow-ts-subnet-ssh-inbound"
    direction = "inbound"
    remote    = ibm_is_subnet.dmz_zone_1.ipv4_cidr_block
    },
    {
      name      = "allow-http-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },
    {
      name      = "allow-traefik-ui-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 8080
        port_max = 8080
      }
    },
    {
      name      = "allow-https-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 443
        port_max = 443
      }
    },
    {
      name      = "allow-all-outbound"
      direction = "outbound"
      remote    = "0.0.0.0/0"
    }
  ]
}
