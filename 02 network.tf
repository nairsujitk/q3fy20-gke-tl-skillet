resource "google_compute_subnetwork" "gkelan-net" {
  name          = "gkelan-net"
  ip_cidr_range = "10.1.1.0/24"
  network       = google_compute_network.gkelan.self_link
  region        = var.region
}

resource "google_compute_network" "gkelan" {
  name                    = "gkelan"
  auto_create_subnetworks = "false"
}