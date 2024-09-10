resource "ibm_tg_gateway" "lab" {
  name           = var.name
  location       = var.region
  global         = false
  resource_group = var.resource_group_id
}

resource "ibm_tg_connection" "hub_connection" {
  gateway      = ibm_tg_gateway.lab.id
  network_type = "vpc"
  name         = "hub-connection"
  network_id   = var.hub_vpc_crn
}

resource "ibm_tg_connection" "prod_connection" {
  gateway      = ibm_tg_gateway.lab.id
  network_type = "vpc"
  name         = "prod-connection"
  network_id   = var.prod_vpc_crn
}

resource "ibm_tg_connection" "dev_connection" {
  gateway      = ibm_tg_gateway.lab.id
  network_type = "vpc"
  name         = "dev-connection"
  network_id   = var.dev_vpc_crn
}