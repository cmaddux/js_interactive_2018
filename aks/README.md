# AKS

## az

1. Authenticate azure (`az login`)
2. Setup RBAC/get credentials
    1. Get appropriate details (`az ad sp create-for-rbac --name="[MEMORABLE NAME]" --role="Contributor" --scopes="/subscriptions/[SUBSCRIPTION ID]"`)
        - Can get subscription ID from `az account list` (is "id" prop in returned JSON)
        - Note that the following details can be retrieved from `az account list`:
            - Subscription ID: Is 'id' prop
        - Note that the following can be retrieved in response to `az ad sp create-for-rbac ...`:
            - Client ID: Is 'appId' prop
            - Client Secret: Is 'password' prop
            - These will be used during terraform step below
        - If you've already done this, can get client ID and client secret with `az ad sp show --id [MEMORABLE NAME]`

## terraform

1. Confirm terraform good to go (`terraform --version`)
2. Initialize terraform (`cd aks && terraform init`)
3. Plan (`cd aks && terraform plan`) and provide required variables
4. Apply (`cd aks && terraform apply`) and provide required variables

## Kubectl

1. Config kubeconfig for AKS (`az aks get-credentials --name [CLUSTER NAME] --resource-group [PROJECT NAME]`)
    - Should update current context to AKS cluster.
    - If need to explicitly change context, use cluster context `kubectl config use-context [CONTEXT NAME]`.
        - Can list cluster contexts with `kubectl config get-contexts`.
2. Make sure OK `kubectl cluster-info`
