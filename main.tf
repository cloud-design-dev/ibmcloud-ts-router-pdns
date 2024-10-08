# If no project prefix is defined, generate a random one 
resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  numeric = false
  upper   = false
}

resource "tailscale_tailnet_key" "lab" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  expiry        = 7776000
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

module "lab_vpc" {
  source            = "./modules/vpc"
  prefix            = local.prefix
  ibmcloud_region   = var.ibmcloud_region
  resource_group_id = module.resource_group.resource_group_id
  tags              = local.tags
  allowed_ssh_ip    = var.allowed_ssh_ip
}

module "tailscale_compute" {
  source                     = "./modules/compute"
  name                       = "${local.prefix}-ts-router"
  zone                       = local.vpc_zones[0].zone
  vpc_id                     = module.lab_vpc.vpc_id
  subnet_id                  = module.lab_vpc.dmz_subnet_id
  resource_group_id          = module.resource_group.resource_group_id
  tags                       = local.tags
  vpc_default_security_group = module.lab_vpc.vpc_default_security_group
  cloud_init = templatefile("./ts-router.yaml", {
    tailscale_tailnet_key  = tailscale_tailnet_key.lab.key
    tailscale_zone1_subnet = module.lab_vpc.zone1_subnet_cidr
    tailscale_zone2_subnet = module.lab_vpc.zone2_subnet_cidr
  })
  ssh_key_ids = local.ssh_key_ids
}

module "workload_compute" {
  depends_on                 = [module.tailscale_compute]
  source                     = "./modules/compute"
  name                       = "${local.prefix}-workload-instance"
  zone                       = local.vpc_zones[0].zone
  vpc_id                     = module.lab_vpc.vpc_id
  subnet_id                  = module.lab_vpc.zone1_subnet_id
  resource_group_id          = module.resource_group.resource_group_id
  tags                       = concat(local.tags, ["environment:production"])
  vpc_default_security_group = module.lab_vpc.services_security_group
  # cloud_init                 = file("./prod-compute.sh")
  cloud_init = templatefile("./prod-compute.sh", {
    pdns_zone = "${local.prefix}-${var.private_dns_zone}"
  })
  ssh_key_ids = local.ssh_key_ids
}

module "pdns" {
  depends_on          = [module.workload_compute]
  source              = "./modules/pdns"
  prefix              = local.prefix
  subnet_crns         = [module.lab_vpc.zone1_subnet_crn, module.lab_vpc.zone2_subnet_crn]
  vpc_crn             = module.lab_vpc.vpc_crn
  dns_zone            = "${local.prefix}-${var.private_dns_zone}"
  tags                = local.tags
  resource_group_id   = module.resource_group.resource_group_id
  workload_compute_ip = module.workload_compute.compute_instance_ip
}

