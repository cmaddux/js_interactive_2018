# Deploying a NodeJS app to your Kubernetes cluster

## Preparation

### Docker

If you can run `docker --version` from the command line, you're good to go. Otherwise, follow [this guide]() to install the Docker for your OS.

### Docker Hub

Create a Docker Hub account [here](https://hub.docker.com/) and create a docker hub repository. Note your username and the name of your Docker hub repository for below.

#### Sign into Docker Hub

1. Sign into docker hub with `docker login --username [USERNAME]`

### Kubectl

If you can run `kubectl version` from the command line, you're good to go. Otherwise, follow [this guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to install kubectl for your OS and preference.

#### Set your context

Set your kubectl context to the context of the cluster you want to deploy to. Use `kubectl config get-contexts` to view all contexts and `kubectl config use-context [CONTEXT]` to set current context.

## Deploy the application

### Push the NodeJS app image to docker hub

1. Build an image for the NodeJS app (`docker build -t [REPOSITORY_NAME]:[VERSION] -f Dockerfile .`).
2. Tag the image for your docker hub repository (`docker tag [REPOSITORY_NAME]:[VERSION] [USERNAME]/[REPOSITORY_NAME]:[VERSION]`).
3. Push the image to your docker hub repository (`docker push [USERNAME]/[REPOSITORY_NAME]:[VERSION]`).

### Prep kuberenetes config file

In the deploy [kubernetes config file](./deploy.yaml), update the image property for the deployment (line 15) to [USERNAME]/[REPOSITORY_NAME]:latest.

### Deploy the app

1. Run `kubectl apply -f deploy.yaml`.
2. Make sure everything is OK `kubectl get all --namespace=js-interactive`.

### Check out your app

1. After a few minutes, check `kubectl get service --namespace=js-interactive`, to see that your service has been given an external IP.
2. Either run `curl http://[EXTERNAL_IP]:3000` or visit http://[EXTERNAL_IP]:3000 to see your app running. 

## Some notes

- In order to pull your image from Docker Hub without credentials, the repository you create will need to be public. If you want to pull from a private repository, you can create a secret for thoe credentials. Find more information [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

- I've used the namespace 'js-interactive' here to organize resources. Find more information on namespaces in kubernetes [here](https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/)
