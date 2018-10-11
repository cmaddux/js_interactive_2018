/**
 * Makes available a list of AWS regions.
 */
data "aws_region" "current" {}

/**
 * Makes available a list of AWS availability zones.
 */
data "aws_availability_zones" "available" {}

/**
 * Makes available the AMI for the current AWS EKS
 * node image. The image is maintained by AWS,
 * so grab from list of AMIs owned by amazon.
 */
data "aws_ami" "eks-worker" {
    filter {
        name   = "name"
        values = ["amazon-eks-node-v*"]
    }

    most_recent = true

    # Below is the account ID for AWS. Don't change this,
    # Amazon owns and maintains the EKS node AMI.
    owners      = ["602401143452"]
}

/**
 * Generates a new 10.0.0.0/16 VPC for our EKS cluster. If you want
 * to add to an existing VPC, simply define the VPC ID
 * in a variable and reference that variable where
 * needed.
 *
 * However, if using an existing VPC, make sure to set
 * the 'kubernetes.io/cluster/{cluster-name}' =
 * 'shared' tag on that VPC.
 */
resource "aws_vpc" "js-interactive-2018" {
    cidr_block = "10.0.0.0/16"

    tags = "${
    map(
         "Name", "js-interactive-2018-node",
         "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
      
    }"

}

/**
 * Generates two subnets for our cluster.
 */
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

/**
 * Generates an internet gateway for our cluster.
 */
resource "aws_internet_gateway" "js-interactive-2018" {
    vpc_id = "${aws_vpc.js-interactive-2018.id}"

    tags {
        Name = "js-interactive-2018"
    }

}

/**
 * Sets up route table to route external traffic through the
 * internet gateway.
 */
resource "aws_route_table" "js-interactive-2018" {
    vpc_id = "${aws_vpc.js-interactive-2018.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.js-interactive-2018.id}"
    }

}

/**
 * Sets up associations between route table and subnets.
 */
resource "aws_route_table_association" "js-interactive-2018" {
    count = 2

    subnet_id      = "${aws_subnet.js-interactive-2018.*.id[count.index]}"
    route_table_id = "${aws_route_table.js-interactive-2018.id}"
}

/**
 * Generates an IAM role for and policy to allow EKS (master) to access
 * other resources on your account.
 */
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

/**
 * Policy attachment for role generated above.
 */
resource "aws_iam_role_policy_attachment" "js-interactive-2018-cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = "${aws_iam_role.js-interactive-2018-cluster.name}"
}

/**
 * Policy attachment for role generated above.
 */
resource "aws_iam_role_policy_attachment" "js-interactive-2018-cluster-AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role       = "${aws_iam_role.js-interactive-2018-cluster.name}"
}

/**
 * Generates a security group to allow communication from master
 * to worker nodes.
 */
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

/**
 * Generates the EKS cluster master.
 */
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

/**
 * Generates an IAM role for for EKS nodes.
 */
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

/**
 * Policy attachment for role generated above.
 */
resource "aws_iam_role_policy_attachment" "js-interactive-2018-node-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = "${aws_iam_role.js-interactive-2018-node.name}"
}

/**
 * Policy attachment for role generated above.
 */
resource "aws_iam_role_policy_attachment" "js-interactive-2018-node-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = "${aws_iam_role.js-interactive-2018-node.name}"
}

/**
 * Policy attachment for role generated above.
 */
resource "aws_iam_role_policy_attachment" "js-interactive-2018-node-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = "${aws_iam_role.js-interactive-2018-node.name}"
}

/**
 * Generates IAM instance profile allowing worker nodes to be claimed
 * by the cluster.
 */
resource "aws_iam_instance_profile" "js-interactive-2018-node" {
    name = "terraform-eks-demo"
    role = "${aws_iam_role.js-interactive-2018-node.name}"
}

/**
 * Generates a security group to allow communication from worker nodes
 * to master.
 */
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

/**
 * Rule allows worker nodes to communicate with each other.
 */
resource "aws_security_group_rule" "js-interactive-2018-node-ingress-self" {
    description              = "Allow node to communicate with each other"
    from_port                = 0
    protocol                 = "-1"
    security_group_id        = "${aws_security_group.js-interactive-2018-node.id}"
    source_security_group_id = "${aws_security_group.js-interactive-2018-node.id}"
    to_port                  = 65535
    type                     = "ingress"
}

/**
 * Rule allows worker nodes to communicate with cluster master.
 */
resource "aws_security_group_rule" "js-interactive-2018-node-ingress-cluster" {
    description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port                = 1025
    protocol                 = "tcp"
    security_group_id        = "${aws_security_group.js-interactive-2018-node.id}"
    source_security_group_id = "${aws_security_group.js-interactive-2018-cluster.id}"
    to_port                  = 65535
    type                     = "ingress"
}

/**
 * Rule allows worker nodes to communicate with cluster master.
 */
resource "aws_security_group_rule" "js-interactive-2018-cluster-ingress-node-https" {
    description              = "Allow pods to communicate with the cluster API Server"
    from_port                = 443
    protocol                 = "tcp"
    security_group_id        = "${aws_security_group.js-interactive-2018-cluster.id}"
    source_security_group_id = "${aws_security_group.js-interactive-2018-node.id}"
    to_port                  = 443
    type                     = "ingress"
}

/**
 * EKS currently documents this required userdata for EKS worker nodes to
 * properly configure Kubernetes applications on the EC2 instance.
 * We utilize a Terraform local here to simplify Base64 encoding this
 * information into the AutoScaling Launch Configuration.
 * More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
 */
locals {
    js-interactive-2018-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.js-interactive-2018.endpoint}' --b64-cluster-ca '${aws_eks_cluster.js-interactive-2018.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA

}

/**
 * Launch config for autoscaling EC2 instances. This takes the place
 * of working directly with EC2 instances.
 */
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

/**
 * Sets base for autoscaling worker nodes.
 */
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
