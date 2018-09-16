locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
  - cluster:
        server: ${aws_eks_cluster.js-interactive-2018.endpoint}
        certificate-authority-data: ${aws_eks_cluster.js-interactive-2018.certificate_authority.0.data}
    name: eks-js-interactive-2018-cluster
contexts:
  - context:
        cluster: eks-js-interactive-2018-cluster
        user: eks-js-interactive-2018-user
    name: eks-js-interactive-2018
current-context: eks-js-interactive-2018
kind: Config
preferences: {}
users:
  - name: eks-js-interactive-2018-user
    user:
        exec:
            apiVersion: client.authentication.k8s.io/v1alpha1
            command: aws-iam-authenticator
            args:
              - "token"
              - "-i"
              - "${var.cluster-name}"
KUBECONFIG
}

output "kubeconfig" {
    value = "${local.kubeconfig}"
}
