/**
 * Defines terraform output for config map that allows the EKS control plane
 * to claim EC2 nodes.
 */
locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
    name: aws-auth
    namespace: kube-system
data:
    mapRoles: |
      - rolearn: ${aws_iam_role.js-interactive-2018-node.arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
CONFIGMAPAWSAUTH

}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}
