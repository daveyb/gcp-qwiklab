variable "shared_secret" {
  type = "string"
}

locals {
  vpn-network-1 = {
    name    = "vpn-network-1"
    region  = "us-central1"
    network = "10.5.4.0/24"
    gateway = "10.5.4.1"
  }

  vpn-network-2 = {
    name    = "vpn-network-2"
    region  = "europe-west1"
    network = "10.1.3.0/24"
    gateway = "10.1.3.1"
  }
}

data "google_compute_network" "network1" {
  name = "${local.vpn-network-1["name"]}"
}

data "google_compute_network" "network2" {
  name = "${local.vpn-network-2["name"]}"
}

resource "google_compute_address" "vpn1" {
  name = "vpn-1-static-ip"
  address_type = "EXTERNAL"
  region = "${local.vpn-network-1["region"]}"
}

resource "google_compute_address" "vpn2" {
  name = "vpn-2-static-ip"
  address_type = "EXTERNAL"
  region = "${local.vpn-network-2["region"]}"
}

resource "google_compute_vpn_gateway" "vpn1" {
  name    = "vpn-1"
  network = "${data.google_compute_network.network1.self_link}"
  region  = "${local.vpn-network-2["region"]}"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn1.address}"
  target      = "${google_compute_vpn_gateway.vpn1.self_link}"
  region  = "${local.vpn-network-2["region"]}"
  depends_on = [
    "google_compute_address.vpn1"
  ]
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${google_compute_address.vpn1.address}"
  target      = "${google_compute_vpn_gateway.vpn1.self_link}"
  region  = "${local.vpn-network-2["region"]}"
  depends_on = [
    "google_compute_address.vpn1"
  ]
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${google_compute_address.vpn1.address}"
  target      = "${google_compute_vpn_gateway.vpn1.self_link}"
  region  = "${local.vpn-network-2["region"]}"
  depends_on = [
    "google_compute_address.vpn1"
  ]
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "tunnel1to2"
  peer_ip       = "${google_compute_address.vpn2.address}"
  shared_secret = "${var.shared_secret}"
  region  = "${local.vpn-network-2["region"]}"

  target_vpn_gateway = "${google_compute_vpn_gateway.vpn1.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_route" "tunnel1to2-route-1" {
  name       = "tunnel1to2-route-1"
  network    = "${data.google_compute_network.network1.name}"
  dest_range = "${local.vpn-network-2["network"]}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel1.self_link}"
}

resource "google_compute_vpn_gateway" "vpn2" {
  name    = "vpn-2"
  network = "${data.google_compute_network.network2.self_link}"
  region  = "${local.vpn-network-2["region"]}"
}

resource "google_compute_forwarding_rule" "fr_esp-2" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn2.address}"
  target      = "${google_compute_vpn_gateway.vpn2.self_link}"
  region  = "${local.vpn-network-2["region"]}"
  depends_on = [
    "google_compute_address.vpn2"
  ]
}

resource "google_compute_forwarding_rule" "fr_udp500-2" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${google_compute_address.vpn2.address}"
  target      = "${google_compute_vpn_gateway.vpn2.self_link}"
  region  = "${local.vpn-network-2["region"]}"
  depends_on = [
    "google_compute_address.vpn2"
  ]
}

resource "google_compute_forwarding_rule" "fr_udp4500-2" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${google_compute_address.vpn2.address}"
  target      = "${google_compute_vpn_gateway.vpn2.self_link}"
  region  = "${local.vpn-network-2["region"]}"
  depends_on = [
    "google_compute_address.vpn2"
  ]
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name          = "tunnel2to1"
  peer_ip       = "${google_compute_address.vpn1.address}"
  shared_secret = "${var.shared_secret}"
  region  = "${local.vpn-network-2["region"]}"
  local_traffic_selector = ["${local.vpn-network-2["network"]}"]

  target_vpn_gateway = "${google_compute_vpn_gateway.vpn2.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp-2",
    "google_compute_forwarding_rule.fr_udp500-2",
    "google_compute_forwarding_rule.fr_udp4500-2",
  ]
}

resource "google_compute_route" "tunnel2to1-route-1" {
  name       = "tunnel2to1-route-1"
  network    = "${data.google_compute_network.network2.name}"
  dest_range = "${local.vpn-network-1["network"]}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel2.self_link}"
}
