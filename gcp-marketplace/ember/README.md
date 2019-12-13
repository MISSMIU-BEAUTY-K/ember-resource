# Overview

Ember™, MetiStream's SaaS-based interactive healthcare analytics platform, uses advanced AI, Natural Language Processing (NLP), and machine learning to enrich and unify all healthcare data types, from clinical, claims, and genomics. With our AI-enabled case search, registry augmentation, and risk predictions, we can tap into that 80% of unstructured data to boost quality and increase revenue.

For more information on Ember, see the [Ember official website](https://www.metistream.com/ember-home/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Ember app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/ember).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command line:

```shell
export CLUSTER=ember-cluster
export ZONE=us-east1-b

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}" --num-nodes 1 --enable-autoscaling --min-nodes 1 --max-nodes 10 --machine-type=custom-8-32768
```

Configure `kubectl` to connect to the new cluster.

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
git clone --recursive https://github.com/MetiStream/ember-resource.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community.
The source code can be found on [github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `ember` directory:

```shell
cd ember-resource/gcp-marketplace/ember
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export RELEASE_NAME=ember
export NAMESPACE=default
```

Configure the container image:

```shell
export TAG=1.0
export REGISTRY="gcr.io/metistream-public/ember"
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

##### Create dedicated Service Accounts

Define the environment variables:

```shell
export EMBER_ACCOUNT="${RELEASE_NAME}-rbac"
```

Expand the manifest to create Service Accounts:

```shell
cat resources/service-accounts.yaml \
  | envsubst '${EMBER_ACCOUNT} \
              ${NAMESPACE} \
              ${RELEASE_NAME}' \
    > "${RELEASE_NAME}_sa_manifest.yaml"
```

Create the accounts on the cluster with `kubectl`:

```shell
kubectl apply -f "${RELEASE_NAME}_sa_manifest.yaml" \
    --namespace "${NAMESPACE}"
```

#### Expand the manifest template

First, add an addtional repo Ember uses as a dependency.

```shell
helm repo add stakater https://stakater.github.io/stakater-charts
```

Then, update helm repo.

```shell
helm repo update
```

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.


```shell
helm template chart/ember \
  --name ${RELEASE_NAME} \
  --namespace=${NAMESPACE} \
  --set serviceAccount=${EMBER_ACCOUNT} \
  --set version=${TAG} \
  > ${RELEASE_NAME}_manifest.yaml
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${RELEASE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${RELEASE_NAME}"
```

To view the app, open the URL in your browser.

### Access Ember UI service
Get the IP of Ember UI service by running

```shell
kubectl --namespace "${NAMESPACE}" get services "${APP_INSTANCE_NAME}-ember-ui-service" --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
You may need to wait for a while before an ip gets assigned.
Use the external IP of the Ember UI service to access Ember

# Backup and Restore

```shell
cd ember-resource/gcp-marketplace/ember/scripts
```

## Backup Ember data to your local environment

Ember uses MongoDB to store metadata.
MongoDB username defaults to be `root`
MongoDB password defaults to be `rootPass`
Backup Ember using the following command:

```shell
export NAMESPACE=default
./backup.sh $APP_INSTANCE_NAME $NAMESPACE [BACKUP_FOLDER] [MONGODB_USERNAME] [MONGODB_PASSWORD]
```

## Restore Ember configuration

```shell
./restore.sh $APP_INSTANCE_NAME $NAMESPACE [BACKUP_FOLDER] [MONGODB_USERNAME] [MONGODB_PASSWORD]
```

# Upgrading the app

The Ember Deployments is configured to roll out updates automatically. Start the update by patching the Deployment with a new image reference:

```shell
kubectl set image deployment ${APP_INSTANCE_NAME}-ember-api --namespace ${NAMESPACE} \
  "${APP_INSTANCE_NAME}-ember-api=[NEW_EMBER_API_IMAGE_REFERENCE]"
kubectl set image deployment ${APP_INSTANCE_NAME}-ember-ui --namespace ${NAMESPACE} \
  "${APP_INSTANCE_NAME}-ember-ui=[NEW_EMBER_UI_IMAGE_REFERENCE]"
kubectl set image deployment ${APP_INSTANCE_NAME}-ember-engine --namespace ${NAMESPACE} \
"${APP_INSTANCE_NAME}-ember-engine=[NEW_EMBER_ENGINE_IMAGE_REFERENCE]"
```

Where `[NEW_EMBER_API_IMAGE_REFERENCE]` and `[NEW_EMBER_UI_IMAGE_REFERENCE]` and `[NEW_EMBER_ENGINE_IMAGE_REFERENCE]` are the Docker image references of the new images that you want to use.

To check the status of Pods, and the progress of
the new image, run the following command:

```shell
kubectl get pods --selector app.kubernetes.io/name=${APP_INSTANCE_NAME} \
  --namespace ${NAMESPACE}
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).
1. From the list of applications, click **Ember**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=ember
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the version of your cluster.
Using the same versions of kubectl and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

Otherwise, delete the resources using types and a label:

```shell
kubectl delete application \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

> **NOTE:** It will delete only the ember application. All ember managed resources will be available.

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
