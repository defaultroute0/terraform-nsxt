# configure some variables first
terraform {
  required_providers {
    # Provider source is used for Terraform discovery and installation of
    # providers. Declare source for all providers required by the module.
    nsxt = {
      source  = "vmware/nsxt"
    }
  }
}
variable "nsx_ip" {
    default = "172.16.10.117"
}
variable "nsx_password" {
    default = "VMware1!VMware1!"
}
variable "nsxt_logical_tier1_router_name" {
    default = "terraformdemo-t1"
}
variable "logicalswitch1_name" {
    default = "tf-web"
}
variable "logicalswitch2_name" {
    default = "tf-app"
}
variable "logicalswitch3_name" {
    default = "tf-db"
}
variable "logicalswitch1_gw" {
    default = "192.168.80.1/24"
}
variable "logicalswitch2_gw" {
    default = "192.168.81.1/24"
}
variable "logicalswitch3_gw" {
    default = "192.168.82.1/24"
}
provider "nsxt" {
  allow_unverified_ssl = true
  host = "${var.nsx_ip}"
  username = "admin"
  password = "${var.nsx_password}"
  max_retries = 10
  retry_min_delay = 500
  retry_max_delay = 5000
  retry_on_status_codes = [429]
}
data "nsxt_transport_zone" "overlay_transport_zone" {
  display_name = "tz-host-overlay"
}

data "nsxt_logical_tier0_router" "tier0_router" {
  display_name = "t0-core"
}

data "nsxt_edge_cluster" "edge_cluster" {
  display_name = "edge-cluster"
}

resource "nsxt_logical_router_link_port_on_tier0" "tier0_port_to_tier1" {
  description = "TIER0_PORT1 provisioned by Terraform"
  display_name = "tier0_port_to_tier1"
  logical_router_id = "${data.nsxt_logical_tier0_router.tier0_router.id}"
  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_tier1_router" "tier1_router" {
  description = "RTR1 provisioned by Terraform"
  display_name = "${var.nsxt_logical_tier1_router_name}"
  #failover_mode = "PREEMPTIVE"
  edge_cluster_id = "${data.nsxt_edge_cluster.edge_cluster.id}"
  enable_router_advertisement = true
  advertise_connected_routes = false
  advertise_static_routes = true
  advertise_nat_routes = true
  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "tier1_port_to_tier0" {
  description  = "TIER1_PORT1 provisioned by Terraform"
  display_name = "tier1_port_to_tier0"
  logical_router_id = "${nsxt_logical_tier1_router.tier1_router.id}"
  linked_logical_router_port_id = "${nsxt_logical_router_link_port_on_tier0.tier0_port_to_tier1.id}"
  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_switch" "LS-terraform-web" {
  admin_state = "UP"
  description = "LogicalSwitch provisioned by Terraform"
  display_name = "${var.logicalswitch1_name}"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_transport_zone.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "app"
    tag = "terraformdemo"
  }
}

resource "nsxt_logical_switch" "LS-terraform-app" {
  admin_state = "UP"
  description = "LogicalSwitch provisioned by Terraform"
  display_name = "${var.logicalswitch2_name}"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_transport_zone.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "app"
    tag = "terraformdemo"
  }
}


resource "nsxt_logical_switch" "LS-terraform-db" {
  admin_state = "UP"
  description = "LogicalSwitch provisioned by Terraform"
  display_name = "${var.logicalswitch3_name}"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_transport_zone.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "app"
    tag = "terraformdemo"
  }
}

resource "nsxt_logical_port" "lp-terraform-web" {
  admin_state = "UP"
  description = "lp provisioned by Terraform"
  display_name = "lp-terraform-web"
  logical_switch_id = "${nsxt_logical_switch.LS-terraform-web.id}"

  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_port" "lp-terraform-app" {
  admin_state = "UP"
  description = "lp provisioned by Terraform"
  display_name = "lp-terraform-app"
  logical_switch_id = "${nsxt_logical_switch.LS-terraform-app.id}"

  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_port" "lp-terraform-db" {
  admin_state = "UP"
  description = "lp provisioned by Terraform"
  display_name = "lp-terraform-db"
  logical_switch_id = "${nsxt_logical_switch.LS-terraform-db.id}"

  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_router_downlink_port" "lif-terraform-web" {
  description = "lif provisioned by Terraform"
  display_name = "lif-terraform-web"
  logical_router_id = "${nsxt_logical_tier1_router.tier1_router.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.lp-terraform-web.id}"
  ip_address = "${var.logicalswitch1_gw}"

  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_router_downlink_port" "lif-terraform-app" {
  description = "lif provisioned by Terraform"
  display_name = "lif-terraform-app"
  logical_router_id = "${nsxt_logical_tier1_router.tier1_router.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.lp-terraform-app.id}"
  ip_address = "${var.logicalswitch2_gw}"

  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_logical_router_downlink_port" "lif-terraform-db" {
  description = "lif provisioned by Terraform"
  display_name = "lif-terraform-db"
  logical_router_id = "${nsxt_logical_tier1_router.tier1_router.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.lp-terraform-db.id}"
  ip_address = "${var.logicalswitch3_gw}"

  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_l4_port_set_ns_service" "ns_service_tcp_443_22_l4" {
  description = "Service provisioned by Terraform"
  display_name = "web_to_app"
  protocol = "TCP"
  destination_ports = ["443", "22"]
  tag {
    scope = "app"
    tag   = "terraformdemo"
  }
}

resource "nsxt_firewall_section" "terraform" {
  description = "FS provisioned by Terraform"
  display_name = "Web-App"
  tag {
    scope = "app"
    tag = "terraformdemo"
  }

  applied_to {
    target_type = "LogicalSwitch"
    target_id = "${nsxt_logical_switch.LS-terraform-web.id}"
  }

  section_type = "LAYER3"
  stateful = true

  rule {
    display_name = "out_rule"
    description  = "Out going rule"
    action = "ALLOW"
    logged = true
    ip_protocol = "IPV4"
    direction = "OUT"

    source {
      target_type = "LogicalSwitch"
      target_id = "${nsxt_logical_switch.LS-terraform-web.id}"
    }

    destination {
      target_type = "LogicalSwitch"
      target_id = "${nsxt_logical_switch.LS-terraform-app.id}"
    }
    service {
      target_type = "NSService"
      target_id = "${nsxt_l4_port_set_ns_service.ns_service_tcp_443_22_l4.id}"
    }
    applied_to {
      target_type = "LogicalSwitch"
      target_id = "${nsxt_logical_switch.LS-terraform-web.id}"
    }
  }
}

output "edge-cluster-id" {
  value = "${data.nsxt_edge_cluster.edge_cluster.id}"
}

output "edge-cluster-deployment_type" {
  value = "${data.nsxt_edge_cluster.edge_cluster.deployment_type}"
}

output "tier0-router-port-id" {
  value = "${nsxt_logical_router_link_port_on_tier0.tier0_port_to_tier1.id}"
}
