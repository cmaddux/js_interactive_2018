# AKS

This guide should help you prepare a kubernetes cluster as easily as possible on AWS AKS. You should end up with a two node kubernetes cluster.

**NOTE: This guide will cost some money. If you clean everything up as mentioned at the bottom of the guide, it shouldn't be much.**

## Preparation

### Azure

You need to have an Azure account. If you don't already have one, go to [https://azure.microsoft.com/en-ca/free/](https://azure.microsoft.com/en-ca/free/) and quickly sign up for an account.

### Azure CLI

If you can run `az --version` from the command line, you're good to go. Otherwise, follow [this guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) to install the Azure CLI for your OS.

#### Configure Azure CLI

1. Authenticate azure (`az login`)
2. Setup RBAC/get credentials
    1. Get appropriate details (`az ad sp create-for-rbac --name="[ANY_NAME]" --role="Contributor" --scopes="/subscriptions/[SUBSCRIPTION_ID]"`)
        - Note: you can get your subscription ID from `az account list` (is the "id" prop in returned JSON)
        - Note: The following used as variables can be retrieved in response to `az ad sp create-for-rbac ...`:
            - Client ID: Is 'appId' prop
            - Client Secret: Is 'password' prop
            - These will be used during terraform step below
        - If you've already done this, you can get client ID and client secret with `az ad sp show --id [MEMORABLE NAME]`.

## terraform

1. Initialize terraform (`terraform init`)
2. Plan (`terraform plan`) and provide required variables
3. Apply (`terraform apply`) and provide required variables

## Kubectl

1. Config kubeconfig for AKS (`az aks get-credentials --name [CLUSTER_NAME] --resource-group [RESOURCE_GROUP_NAME]`)
    - The cluster name and resource group name are defined [here](./variables.tf)
    - This should update current context to AKS cluster.
    - If need to explicitly change context, use cluster context `kubectl config use-context [CONTEXT NAME]`.
        - Can list cluster contexts with `kubectl config get-contexts`.
2. Make sure OK `kubectl cluster-info` and `kubectl get all`. This should show a single kuberentes service (which is your master).

## Deploy app

Follow [this guide](./../app/README.md) to deploy an application to your AKS cluster.

## Clean up

1. Destroy all resources (`terraform destroy`).
