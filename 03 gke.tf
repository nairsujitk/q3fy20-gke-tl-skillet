resource "google_container_cluster" "gke-cluster" {
  name = var.cluster_name
  location = var.region_zone

  initial_node_count = 3


  network    = google_compute_network.gkelan.name
  subnetwork = google_compute_subnetwork.gkelan-net.name

  master_auth {
    username = var.username
    password = var.password
  }

  node_config {
    machine_type = "n1-standard-4"
    image_type   = "Ubuntu"

    metadata = {
        disable-legacy-endpoints = "true"
    }

    labels = {
        cluster = "pcce-demo-gke"
    }

    tags = ["cluster", "pcce-demo-gke"]

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

  }
}
