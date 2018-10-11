terraform {
  required_version = ">= 0.11.0"
}

provider "google" {
  credentials = "${var.gcp_credentials}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

resource "google_container_cluster" "js-interactive-cluster" {
  name               = "${var.cluster_name}"
  description        = "Example k8s cluster for JS Interactive"
  zone               = "${var.gcp_zone}"
  initial_node_count = "${var.initial_node_count}"
  enable_kubernetes_alpha = "true"
  enable_legacy_abac = "true"
  min_master_version = "1.10.7-gke.2"

  node_config {
    machine_type = "${var.node_machine_type}"
    disk_size_gb = "${var.node_disk_size}"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}
