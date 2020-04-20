resource "null_resource"  "configure_kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.gke-cluster.name} --zone ${var.region_zone} --project ${var.project_name}"
  }
  depends_on = [google_container_cluster.gke-cluster]
}

resource "null_resource"  "delay_pod_creation" {
  provisioner "local-exec" {
    command = "sleep 20"
  }
  depends_on = [null_resource.configure_kubectl]
}