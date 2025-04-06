resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name       = "${var.cluster_name}-subnet"
  cidr       = var.subnet_cidr
  vpc_id     = opentelekomcloud_vpc_v1.vpc.id
  gateway_ip = cidrhost(var.subnet_cidr, 1)
  dns_list   = ["100.125.4.25", "8.8.8.8"]
}

resource "opentelekomcloud_networking_secgroup_v2" "secgroup" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for ${var.cluster_name}"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "internal_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = var.vpc_cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "admin_ssh_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.admin_cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "admin_api_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = var.admin_cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.secgroup.id
}