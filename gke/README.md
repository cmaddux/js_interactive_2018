# GKE

## Via Google Cloud Console

1. Create a Google Cloud account
2. Go to the Kubernetes Engine page in the console
3. Click project in top left corner
4. Click 'New Project' in popup
5. Enter a project name and click 'Create'. (Remember that project name, you'll need it later)
6. Wait for project to initialize
7. Change to new project
8. Wait for API and related services to be enabled (You don't have to do anything, this can take a while.)

(The 'Before you begin' part of the [GKE Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart))

9. Go to 'APIs and Services' > 'Credentials'
10. Click 'Create Credentials' > 'Service Account Key'
11. Select 'New Service Account', give it a name, set role to 'Kubernetes Engine' > 'Kubernetes Engine Cluster Admin' and 'Service Accounts' > 'Service Account User'
12. Click 'Create' and hang on to downloaded key

(The 'Configuration Reference' > 'credentials' part of [this guide](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file)

## Gcloud

1. Authenticate gcloud (`gcloud auth login`)
2. Set project (`gcloud config set project [PROJECT NAME]`)
3. Set zone (`gcloud config set zone [PROJECT ZONE]`)

## Terraform

1. Confirm terraform good to go (`terraform --version`)
2. Initialize terraform (`cd gke && terraform init`)
3. Plan (`cd gke && terraform plan`) and provide required variables
4. Apply (`cd gke && terraform apply`) and provide required variables

## Kubectl

1. Write kubeconfig for gcloud cluster `terraform output kubeconfig > ~/.kube/config-gke-[PROJECT NAME]`
2. Add the newly created config to KUBECONFIG
    1. Open `~/.profile`
    2. Add line `KUBECONFIG=~/.kube/config:~/.kube/config-gke-[PROJECT NAME]`
    3. Re-source profile `source ~/.profile`
3. Use cluster context `kubectl config use-context [CONTEXT NAME]`
4. Make sure OK `kubectl cluster-info`

## Deploy app

Follow [this guide](./../app/README.md) to deploy an application to your GKE cluster.

## Clean up

1. Destroy all resources (`terraform destroy`).
