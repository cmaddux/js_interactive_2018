data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

variable "aws-account-id" {}
variable "local-ip-address" {}

data "aws_ami" "eks-worker" {
    filter {
        name   = "name"
        values = ["amazon-eks-node-v*"]
    }

    most_recent = true
    owners      = ["${variable.aws-account-id}"] # Amazon Account ID
}

resource "aws_vpc" "js-interactive-2018" {
    cidr_block = "10.0.0.0/16"

    tags = "${
    map(
         "Name", "js-interactive-2018-node",
         "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
      
    }"

}

resource "aws_subnet" "js-interactive-2018" {
    count = 2

    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    cidr_block        = "10.0.${count.index}.0/24"
    vpc_id            = "${aws_vpc.js-interactive-2018.id}"

    tags = "${
        map(
             "Name", "js-interactive-2018-node",
             "kubernetes.io/cluster/${var.cluster-name}", "shared",
        )
    }"

}

resource "aws_internet_gateway" "js-interactive-2018" {
    vpc_id = "${aws_vpc.js-interactive-2018.id}"

    tags {
        Name = "js-interactive-2018"
    }

}

resource "aws_route_table" "js-interactive-2018" {
    vpc_id = "${aws_vpc.js-interactive-2018.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.js-interactive-2018.id}"
    }

}

resource "aws_route_table_association" "js-interactive-2018" {
    count = 2

    subnet_id      = "${aws_subnet.js-interactive-2018.*.id[count.index]}"
    route_table_id = "${aws_route_table.js-interactive-2018.id}"
}

resource "aws_iam_role" "js-interactive-2018-cluster" {
  name = "js-interactive-2018-cluster"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "js-interactive-2018-cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = "${aws_iam_role.js-interactive-2018-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "js-interactive-2018-cluster-AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role       = "${aws_iam_role.js-interactive-2018-cluster.name}"
}

resource "aws_security_group" "js-interactive-2018-cluster" {
    name        = "js-interactive-2018-cluster"
    description = "Cluster communication with worker nodes"
    vpc_id      = "${aws_vpc.js-interactive-2018.id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "js-interactive-2018"
    }

}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "js-interactive-2018-cluster-ingress-workstation-https" {
    cidr_blocks       = ["${variables.local-ip-address}/32"]
    description       = "Allow workstation to communicate with the cluster API Server"
    from_port         = 443
    protocol          = "tcp"
    security_group_id = "${aws_security_group.js-interactive-2018-cluster.id}"
    to_port           = 443
    type              = "ingress"
}

resource "aws_eks_cluster" "js-interactive-2018" {
    name            = "${var.cluster-name}"
    role_arn        = "${aws_iam_role.js-interactive-2018-cluster.arn}"

    vpc_config {
        security_group_ids = ["${aws_security_group.js-interactive-2018-cluster.id}"]
        subnet_ids         = ["${aws_subnet.js-interactive-2018.*.id}"]
    }

    depends_on = [
        "aws_iam_role_policy_attachment.js-interactive-2018-cluster-AmazonEKSClusterPolicy",
        "aws_iam_role_policy_attachment.js-interactive-2018-cluster-AmazonEKSServicePolicy",
    ]

}

resource "aws_iam_role" "js-interactive-2018-node" {
  name = "js-interactive-2018-node"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "js-interactive-2018-node-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = "${aws_iam_role.js-interactive-2018-node.name}"
}

resource "aws_iam_role_policy_attachment" "js-interactive-2018-node-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = "${aws_iam_role.js-interactive-2018-node.name}"
}

resource "aws_iam_role_policy_attachment" "js-interactive-2018-node-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = "${aws_iam_role.js-interactive-2018-node.name}"
}

resource "aws_iam_instance_profile" "js-interactive-2018-node" {
    name = "terraform-eks-demo"
    role = "${aws_iam_role.js-interactive-2018-node.name}"
}

resource "aws_security_group" "js-interactive-2018-node" {
    name        = "js-interactive-2018-node"
    description = "Security group for all nodes in the cluster"
    vpc_id      = "${aws_vpc.js-interactive-2018.id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = "${
        map(
             "Name", "js-interactive-2018-node",
             "kubernetes.io/cluster/${var.cluster-name}", "owned",
        )
    }"

}

resource "aws_security_group_rule" "js-interactive-2018-node-ingress-self" {
    description              = "Allow node to communicate with each other"
    from_port                = 0
    protocol                 = "-1"
    security_group_id        = "${aws_security_group.js-interactive-2018-node.id}"
    source_security_group_id = "${aws_security_group.js-interactive-2018-node.id}"
    to_port                  = 65535
    type                     = "ingress"
}

resource "aws_security_group_rule" "js-interactive-2018-node-ingress-cluster" {
    description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port                = 1025
    protocol                 = "tcp"
    security_group_id        = "${aws_security_group.js-interactive-2018-node.id}"
    source_security_group_id = "${aws_security_group.js-interactive-2018-cluster.id}"
    to_port                  = 65535
    type                     = "ingress"
}

resource "aws_security_group_rule" "js-interactive-2018-cluster-ingress-node-https" {
    description              = "Allow pods to communicate with the cluster API Server"
    from_port                = 443
    protocol                 = "tcp"
    security_group_id        = "${aws_security_group.js-interactive-2018-cluster.id}"
    source_security_group_id = "${aws_security_group.js-interactive-2018-node.id}"
    to_port                  = 443
    type                     = "ingress"
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
    js-interactive-2018-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.js-interactive-2018.endpoint}' --b64-cluster-ca '${aws_eks_cluster.js-interactive-2018.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA

}

resource "aws_launch_configuration" "js-interactive-2018" {
    associate_public_ip_address = true
    iam_instance_profile        = "${aws_iam_instance_profile.js-interactive-2018-node.name}"
    image_id                    = "${data.aws_ami.eks-worker.id}"
    instance_type               = "m4.large"
    name_prefix                 = "js-interactive-2018"
    security_groups             = ["${aws_security_group.js-interactive-2018-node.id}"]
    user_data_base64            = "${base64encode(local.js-interactive-2018-node-userdata)}"

    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_autoscaling_group" "js-interactive-2018" {
    desired_capacity     = 2
    launch_configuration = "${aws_launch_configuration.js-interactive-2018.id}"
    max_size             = 2
    min_size             = 1
    name                 = "js-interactive-2018"
    vpc_zone_identifier  = ["${aws_subnet.js-interactive-2018.*.id}"]

    tag {
        key                 = "Name"
        value               = "js-interactive-2018"
        propagate_at_launch = true
    }

    tag {
        key                 = "kubernetes.io/cluster/${var.cluster-name}"
        value               = "owned"
        propagate_at_launch = true
    }

}
