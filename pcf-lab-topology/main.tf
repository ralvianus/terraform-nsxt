#
# Configure the VMware NSX provider to connect to the NSX
# REST API running on the NSX manager.
#

terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
  required_version = ">= 0.13"
}

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
  display_name = "edge-cluster-1"
}

data "nsxt_policy_transport_zone" "tz-host-overlay" {
  display_name = "nsx-overlay-transportzone"
}

data "nsxt_policy_tier0_gateway" "t0-gateway" {
  display_name = "T0-TAS"
}

data "nsxt_policy_tier1_gateway" "t1-tas" {
  display_name = "T1-Router-TAS-Deployment"
}

data "nsxt_policy_dhcp_server" "dhcp-server" {
  display_name     = "DHCP config TAS"
}

# Creating Tier1-Gateway

resource "nsxt_policy_tier1_gateway" "t1_avi" {
  nsx_id                    = "t1-avi"
  display_name              = "t1-avi"
  description               = "Tier1-avi provisioned by Terraform"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster.path
  dhcp_config_path          = data.nsxt_policy_dhcp_server.dhcp-server.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "false"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0-gateway.path
  route_advertisement_types = ["TIER1_CONNECTED"]
  pool_allocation           = "ROUTING"
}

# Creating Segments

resource "nsxt_policy_segment" "avi-mgmt-00" {
  nsx_id              = "avi-mgmt-00"
  display_name        = "avi-mgmt-00"
  description         = "Terraform provisioned avi-mgmt-00 Segment"
  connectivity_path   = nsxt_policy_tier1_gateway.t1_avi.path
  transport_zone_path = data.nsxt_policy_transport_zone.tz-host-overlay.path

  subnet {
    cidr        = "10.20.10.1/24"
    dhcp_ranges = ["10.20.10.51-10.20.10.100"]

    dhcp_v4_config {
      server_address = "100.96.0.1/30"
      lease_time     = 36000
      dns_servers    = ["192.168.110.10"]
      }
  }
}

resource "nsxt_policy_segment" "ls-tas-deployment-01" {
  nsx_id              = "ls-tas-deployment-01"
  display_name        = "ls-tas-deployment-01"
  description         = "Terraform provisioned ls-tas-deployment-01 Segment"
  connectivity_path   = data.nsxt_policy_tier1_gateway.t1-tas.path
  transport_zone_path = data.nsxt_policy_transport_zone.tz-host-overlay.path

  subnet {
    cidr        = "10.20.20.1/24"
    dhcp_ranges = ["10.20.20.51-10.20.20.100"]

    dhcp_v4_config {
      server_address = "100.96.0.1/30"
      lease_time     = 36000
      dns_servers    = ["192.168.110.10"]
      }
  }
}
