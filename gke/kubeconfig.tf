locals {
    kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
    - name: js-interactive-cluster
      cluster:
        server: https://${google_container_cluster.js-interactive-cluster.endpoint}
        certificate-authority-data: ${google_container_cluster.js-interactive-cluster.master_auth.0.cluster_ca_certificate}
contexts:
    - context:
        cluster: js-interactive-cluster
        user: js-interactive-user
      name: js-interactive-context
current-context: js-interactive-context
kind: Config
preferences: {}
users:
    - name: js-interactive-user
      user:
        auth-provider:
            config: null
            name: gcp
KUBECONFIG
}

output "kubeconfig" {
    value = "${local.kubeconfig}"
}
