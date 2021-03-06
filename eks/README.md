# EKS

This guide should help you prepare a kubernetes cluster as easily as possible on AWS EKS. You should end up with a two node kubernetes cluster.

**NOTE: This guide will cost some money. If you clean everything up as mentioned at the bottom of the guide, it shouldn't be much.**

## Preparation

### AWS

You need to have an AWS account. If you don't already have one, go to [https://aws.amazon.com](https://aws.amazon.com) and quickly sign up for an account.

### AWS CLI

If you can run `aws --version` from the command line, you're good to go. Otherwise, follow [this guide](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) to install the AWS CLI for your OS.

#### Get your Access Key ID and Access Key

1. Go to [https://console.aws.amazon.com](https://console.aws.amazon.com)
2. Under 'Services' find the IAM service.
3. Click 'Users'.
4. Select your name.
5. Select the 'Security Credentials' tab.
6. Under 'Access Keys', click 'Create access key'.
7. Note the created 'Access Key ID' and 'Secret Access Key'.

#### Configure AWS CLI

1. Configure AWS CLI (`aws configure`).
2. When asked for ACCESS_KEY_ID, enter value noted above.
3. When asked for ACCESS_KEY_SECRET, enter value noted above.

### AWS IAM Authenticator

If you can run `aws-iam-authenticator --help` from the command line, you're good to go. Otherwise, follow [this guide](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) (Find the 'To install aws-iam-authenticator for Amazon EKS' heading) to install aws-iam-authenticator for your OS.

### Terraform

If you can run `terraform --version` from the command line, you're good to go. Otherwise, follow [this guide](https://www.terraform.io/intro/getting-started/install.html) to install Terraform.

### Kubectl

If you can run `kubectl version` from the command line, you're good to go. Otherwise, follow [this guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to install kubectl for your OS and preference.

## Creating the cluster

1. Initialize terraform (`cd eks && terraform init`)
2. Plan (`cd eks && terraform plan`) and provide required variables
3. Apply (`cd eks && terraform apply`) and provide required variables

## Connecting to the cluster

1. Use the AWS CLI to update kubeconfig for cluster (`aws eks update-kubeconfig --name [CLUSTER NAME]`)
    - The cluster name is defined [here](./variables.tf)
    - **Note: update-kubeconfig is relatively new to AWS CLI. If you run into issues, make sure you have the most recent version (>= 1.16.27)**
2. This should automatically switch you to EKS context, to confirn use `kubectl config current-context`
    - If need to switch, view all available contexts with `kubectl config get-contexts`
    - Switch to the EKS cluster context with `kubectl config use-context [CONTEXT NAME]`
3. Make sure OK `kubectl cluster-info` and `kubectl get all`. This should show a single kuberentes service (which is your master).

## Allowing the cluster to claim worker nodes

1. Create config map (`terraform output config-map-aws-auth > config-map-aws-auth.yaml`).
2. Apply config map (`kubectl apply -f config-map-aws-auth.yaml`).
3. Make sure nodes join the cluster (`kubectl get nodes --watch`). Wait for two nodes to show 'Ready'.

## Deploy app

Follow [this guide](./../app/README.md) to deploy an application to your EKS cluster.

## Clean up

1. Destroy all resources (`terraform destroy`).
