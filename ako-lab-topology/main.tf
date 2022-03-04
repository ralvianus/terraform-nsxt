#
# Configure the VMware NSX provider to connect to the NSX
# REST API running on the NSX manager.
#

provider "nsxt" {
  host                  = var.nsxt_host
  username              = var.nsxt_username
  password              = var.nsxt_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

# This part of the example shows some data sources we will need to refer to
# later in the .tf file. They include the transport zone, tier 0 router and
# edge cluster.

data "nsxt_policy_edge_cluster" "edge-cluster" {
  display_name = "edge-cluster"
}

data "nsxt_policy_transport_zone" "tz-host-overlay" {
  display_name = "tz-host-overlay"
}

data "nsxt_policy_tier0_gateway" "t0-gateway" {
  display_name = "t0-core"
}

data "nsxt_policy_dhcp_server" "dhcp-server" {
  display_name     = "dhcp-server"
}

# Creating Tier1-Gateway

resource "nsxt_policy_tier1_gateway" "t1_east" {
  nsx_id                    = "t1-east"
  display_name              = "t1-east"
  description               = "Tier1-east provisioned by Terraform"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster.path
  dhcp_config_path          = nsxt_policy_dhcp_server.dhcp-server.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "false"
  enable_standby_relocation = "false"
  force_whitelisting        = "true"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0_gateway.path
  route_advertisement_types = ["TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"
}

resource "nsxt_policy_tier1_gateway" "t1_west" {
  nsx_id                    = "t1-west"
  display_name              = "t1-west"
  description               = "Tier1-west provisioned by Terraform"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster.path
  dhcp_config_path          = nsxt_policy_dhcp_server.dhcp-server.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "false"
  enable_standby_relocation = "false"
  force_whitelisting        = "true"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0_gateway.path
  route_advertisement_types = ["TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"
}

resource "nsxt_policy_tier1_gateway" "t1_avi" {
  nsx_id                    = "t1-avi"
  display_name              = "t1-avi"
  description               = "Tier1-avi provisioned by Terraform"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "false"
  enable_standby_relocation = "false"
  force_whitelisting        = "true"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0_gateway.path
  route_advertisement_types = ["TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"
}

# Creating Segments
resource "nsxt_policy_segment" "ocp-east-00" {
  nsx_id              = "ocp-east-00"
  display_name        = "ocp-east-00"
  description         = "Terraform provisioned ocp-east-00 Segment"
  connectivity_path   = nsxt_policy_tier1_gateway.t1_east.path
  transport_zone_path = data.nsxt_policy_transport_zone.tz-host-overlay.path

  subnet {
    cidr        = "10.10.10.1/24"
    dhcp_ranges = ["10.10.10.51-10.10.10.100"]

    dhcp_v4_config {
      server_address = "100.96.0.1/30"
      lease_time     = 36000
      }
    }
  }
}

resource "nsxt_policy_segment" "ocp-west-00" {
  nsx_id              = "ocp-west-00"
  display_name        = "ocp-west-00"
  description         = "Terraform provisioned ocp-west-00 Segment"
  connectivity_path   = nsxt_policy_tier1_gateway.t1_west.path
  transport_zone_path = data.nsxt_policy_transport_zone.tz-host-overlay.path

  subnet {
    cidr        = "10.10.20.1/24"
    dhcp_ranges = ["10.10.20.51-10.10.20.100"]

    dhcp_v4_config {
      server_address = "100.96.0.1/30"
      lease_time     = 36000
      }
    }
  }
}

resource "nsxt_policy_segment" "avi-mgmt-00" {
  nsx_id              = "avi-mgmt-00"
  display_name        = "avi-mgmt-00"
  description         = "Terraform provisioned avi-mgmt-00 Segment"
  connectivity_path   = nsxt_policy_tier1_gateway.t1_avi.path
  transport_zone_path = data.nsxt_policy_transport_zone.tz-host-overlay.path

  subnet {
    cidr        = "10.20.10.1/24"
    }
  }
}
