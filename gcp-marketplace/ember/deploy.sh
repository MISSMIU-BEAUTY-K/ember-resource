#!/bin/bash

docker rmi -f gcr.io/ember-159719/ember/deployer

export REGISTRY=gcr.io/$(gcloud config get-value project | tr ':' '/')
export APP_NAME=ember
export NAMESPACE="test-ns"
export EMBER_ACCOUNT="ember-rbac"
export RELEASE_NAME="test-deployment"
apiImage="${REGISTRY}/ember-api:ember-1667"
engineImage="${REGISTRY}/ember-engine:ember-1657"
uiImage="${REGISTRY}/ember-ui:ember-1657-2"

cat resources/service-accounts.yaml| envsubst '${EMBER_ACCOUNT} ${NAMESPACE} ${RELEASE_NAME}' > ember_sa_manifest.yaml

kubectl apply -f ember_sa_manifest.yaml --namespace "${NAMESPACE}"

docker build --tag $REGISTRY/$APP_NAME/deployer .

docker push $REGISTRY/$APP_NAME/deployer

#mpdev /scripts/install --deployer=$REGISTRY/$APP_NAME/deployer  \
#--parameters='{"name": "test-deployment", "namespace": "test-ns", "loadBalancerType": "Internal", "serviceAccount":'\""${EMBER_ACCOUNT}"\"', "apiImage":"gcr.io/ember-159719/ember-api:ember-1667","engineImage":"gcr.io/ember-159719/ember-engine:ember-1657","uiImage":"gcr.io/ember-159719/ember-ui:ember-1657-2"}'


mpdev /scripts/install --deployer=$REGISTRY/$APP_NAME/deployer  \
--parameters='{"name": "test-deployment", "namespace": "test-ns", "serviceAccount":'\""${EMBER_ACCOUNT}"\"'}'
