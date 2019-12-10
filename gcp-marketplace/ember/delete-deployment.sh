#!/bin/bash

kubectl delete applications --all --namespace test-ns
kubectl delete pvc -l "release=test-deployment" --namespace=test-ns
kubectl delete pvc -l app=test-deployment-mongo --namespace=test-ns
kubectl delete storageclass standard
