# If no project prefix is defined, generate a random one 
resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  numeric = false
  upper   = false
}

resource "tailscale_tailnet_key" "lab" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  description   = "Demo tailscale key for lab"
}

# If an existing resource group is provided, this module returns the ID, otherwise it creates a new one and returns the ID
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

resource "tls_private_key" "ssh" {
  count     = var.existing_ssh_key != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "generated_key" {
  count          = var.existing_ssh_key != "" ? 0 : 1
  name           = "${local.prefix}-${var.ibmcloud_region}-sshkey"
  resource_group = module.resource_group.resource_group_id
  public_key     = tls_private_key.ssh.0.public_key_openssh
  tags           = local.tags
}

resource "ibm_is_vpc" "demo" {
  name                        = var.vpc_name
  resource_group              = var.resource_group_id
  classic_access              = var.classic_access
  address_prefix_management    = var.default_address_prefix
  default_network_acl_name    = "${var.vpc_name}-default-acl"
  default_security_group_name = "${var.vpc_name}-default-sg"
  default_routing_table_name  = "${var.vpc_name}-default-rt"
  tags                        = local.tags
}

module "add_rules_to_default_vpc_security_group" {
  depends_on                   = [module.hub_vpc]
  source                       = "terraform-ibm-modules/security-group/ibm"
  add_ibm_cloud_internal_rules = true
  use_existing_security_group  = true
  existing_security_group_name = ibm_is_vpc.demo.default_security_group_name
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
      name      = "allow-https-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 443
        port_max = 443
      }
    }
  ]
  tags = local.tags
}

module "ts_router" {
  source                     = "./modules/compute"
  name                       = "${local.prefix}-ts-router"
  zone                       = local.vpc_zones[0].zone
  vpc_id                     = module.hub_vpc.vpc_id
  subnet_id                  = module.hub_vpc.vpc_subnet_id
  resource_group_id          = module.resource_group.resource_group_id
  tags                       = concat(local.tags, ["environment:hub"])
  vpc_default_security_group = module.hub_vpc.default_security_group
  cloud_init = templatefile("./ts-router.yaml", {
    tailscale_tailnet_key = tailscale_tailnet_key.lab.key
  })
  ssh_key_ids = local.ssh_key_ids
}

module "prod_compute" {
  depends_on                 = [module.ts_router]
  source                     = "./modules/compute"
  name                       = "${local.prefix}-prod-instance"
  zone                       = local.vpc_zones[0].zone
  vpc_id                     = module.prod_vpc.vpc_id
  subnet_id                  = module.prod_vpc.vpc_subnet_id
  resource_group_id          = module.resource_group.resource_group_id
  tags                       = concat(local.tags, ["environment:production"])
  vpc_default_security_group = module.prod_vpc.default_security_group
  cloud_init                 = file("./generic.yaml")
  ssh_key_ids                = local.ssh_key_ids
}

module "dev_compute" {
  depends_on                 = [module.prod_compute]
  source                     = "./modules/compute"
  name                       = "${local.prefix}-dev-instance"
  zone                       = local.vpc_zones[0].zone
  vpc_id                     = module.dev_vpc.vpc_id
  subnet_id                  = module.dev_vpc.vpc_subnet_id
  resource_group_id          = module.resource_group.resource_group_id
  tags                       = concat(local.tags, ["environment:development"])
  vpc_default_security_group = module.dev_vpc.default_security_group
  cloud_init                 = file("./generic.yaml")
  ssh_key_ids                = local.ssh_key_ids
}

#module "tailscale" {
#  depends_on         = [module.dev_compute]
#  source             = "./modules/tailscale"
#  lab_routes         = [local.hub_subnet_cidr, local.prod_subnet_cidr, local.dev_subnet_cidr]
#  ts_router_hostname = "${local.prefix}-ts-router"
#}
