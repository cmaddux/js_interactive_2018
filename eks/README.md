# EKS

# Preparation

1. Make sure aws-cli connected to account (`aws configure` and set Access Key ID, Access Key, ...)
    - Or if using profiles, `export AWS_PROFILE=[PROFILE NAME]`
2. Install/setup aws-iam-authenticator (`aws-iam-authenticator --version`)
    - Guide here [https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
3. Make sure using kubectl version > 1.10 on client (`kubectl version`)

# terraform

1. Confirm terraform good to go (`terraform --version`)
2. Initialize terraform (`cd eks && terraform init`)
3. Plan (`cd eks && terraform plan`) and provide required variables
4. Apply (`cd eks && terraform apply`) and provide required variables

# kubectl

1. Write kubeconfig for gcloud cluster `terraform output kubeconfig > ~/.kube/config-eks-[PROJECT NAME]`
2. Add the newly created config to KUBECONFIG
    1. Open `~/.profile`
    2. Add line `KUBECONFIG=~/.kube/config:~/.kube/config-gke-[PROJECT NAME]`
    3. Re-source profile `source ~/.profile`
3. Use cluster context `kubectl config use-context [CONTEXT NAME]`
4. Make sure OK `kubectl cluster-info`

# Joining worker nodes

1. Create config map (`terraform ouput config-map-aws-auth > config-map-aws-auth.yaml`)
2. Apply config map (`kubectl apply -f config-map-aws-auth.yaml`)
3. Make sure nodes join (`kubectl get nodes --watch`)
