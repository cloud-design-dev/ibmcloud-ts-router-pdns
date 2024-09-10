data "ibm_is_image" "base" {
  name = var.base_image
}

resource "ibm_is_virtual_network_interface" "compute" {
  allow_ip_spoofing         = true
  auto_delete               = false
  enable_infrastructure_nat = true
  name                      = "${var.name}-vnic"
  subnet                    = var.subnet_id
  resource_group            = var.resource_group_id
  security_groups           = [var.vpc_default_security_group]
  tags                      = concat(var.tags, ["zone:${var.zone}"])
}

resource "ibm_is_instance" "compute" {
  name           = var.name
  vpc            = var.vpc_id
  image          = data.ibm_is_image.base.id
  profile        = var.instance_profile
  resource_group = var.resource_group_id
  metadata_service {
    enabled            = true
    protocol           = "https"
    response_hop_limit = 5
  }

  boot_volume {
    auto_delete_volume = true
  }
  user_data = var.cloud_init
  #   user_data = file("${path.module}/cloud-init.yaml")
  primary_network_attachment {
    name = "${var.name}-primary-interface"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.compute.id
    }
  }

  zone = var.zone
  keys = var.ssh_key_ids
  tags = concat(var.tags, ["zone:${var.zone}"])
}

