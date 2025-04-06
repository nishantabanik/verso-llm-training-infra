resource "opentelekomcloud_cce_cluster_v3" "cluster" {
  name                   = var.cluster_name
  flavor_id              = "cce.s2.large"
  vpc_id                 = opentelekomcloud_vpc_v1.vpc.id
  subnet_id              = opentelekomcloud_vpc_subnet_v1.subnet.id
  container_network_type = "overlay_l2"
  authentication_mode    = "rbac"
  
  masters {
    availability_zone = var.availability_zones[0]
  }
  
  masters {
    availability_zone = var.availability_zones[1]
  }
  
  masters {
    availability_zone = var.availability_zones[2]
  }
}

resource "opentelekomcloud_cce_node_v3" "standard_nodes" {
  count             = var.node_count
  cluster_id        = opentelekomcloud_cce_cluster_v3.cluster.id
  name              = "${var.cluster_name}-node-${count.index}"
  flavor_id         = var.node_flavor
  availability_zone = element(var.availability_zones, count.index % length(var.availability_zones))
  key_pair          = opentelekomcloud_compute_keypair_v2.keypair.name
  
  root_volume {
    size       = 100
    volumetype = "SSD"
  }
  
  data_volumes {
    size       = 500
    volumetype = "SSD"
  }
}

resource "opentelekomcloud_cce_node_v3" "gpu_nodes" {
  count             = var.gpu_node_count
  cluster_id        = opentelekomcloud_cce_cluster_v3.cluster.id
  name              = "${var.cluster_name}-gpu-node-${count.index}"
  flavor_id         = var.gpu_node_flavor
  availability_zone = element(var.availability_zones, count.index % length(var.availability_zones))
  key_pair          = opentelekomcloud_compute_keypair_v2.keypair.name
  
  root_volume {
    size       = 100
    volumetype = "SSD"
  }
  
  data_volumes {
    size       = 1000
    volumetype = "SSD"
  }
  
  labels = {
    "accelerator" = "nvidia"
    "use"         = "llm-training"
  }
}

resource "opentelekomcloud_compute_keypair_v2" "keypair" {
  name       = "${var.cluster_name}-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "opentelekomcloud_vpc_eip_v1" "bastion_eip" {
  bandwidth {
    name        = "${var.cluster_name}-bastion-bandwidth"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
  publicip {
    type = "5_bgp"
  }
}

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name              = "${var.cluster_name}-bastion"
  image_name        = "Standard_Ubuntu_22.04_latest"
  flavor_name       = "s3.medium.4"
  key_pair          = opentelekomcloud_compute_keypair_v2.keypair.name
  security_groups   = [opentelekomcloud_networking_secgroup_v2.secgroup.name]
  availability_zone = var.availability_zones[0]
  
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common python3-pip unzip
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
    unzip terraform_1.6.0_linux_amd64.zip
    mv terraform /usr/local/bin/
    pip3 install otc-cli
  EOF
}

resource "opentelekomcloud_networking_floatingip_associate_v2" "bastion_ip_associate" {
  floating_ip = opentelekomcloud_vpc_eip_v1.bastion_eip.publicip[0].ip_address
  port_id     = opentelekomcloud_compute_instance_v2.bastion.network[0].port
  depends_on  = [opentelekomcloud_compute_instance_v2.bastion]
}