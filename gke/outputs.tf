output "k8s_endpoint" {
  value = "${google_container_cluster.js-interactive-cluster.endpoint}"
}

output "k8s_master_version" {
  value = "${google_container_cluster.js-interactive-cluster.master_version}"
}

output "k8s_instance_group_urls" {
  value = "${google_container_cluster.js-interactive-cluster.instance_group_urls.0}"
}

output "k8s_master_auth_client_certificate" {
  value = "${google_container_cluster.js-interactive-cluster.master_auth.0.client_certificate}"
}

output "k8s_master_auth_client_key" {
  value = "${google_container_cluster.js-interactive-cluster.master_auth.0.client_key}"
}

output "k8s_master_auth_cluster_ca_certificate" {
  value = "${google_container_cluster.js-interactive-cluster.master_auth.0.cluster_ca_certificate}"
}
