#!/bin/bash

set -Eeuxo pipefail

export PATH=$GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64:$PATH

echo "Create Kubernetes cluster with kind..."
kind create cluster --image kindest/node:latest
export KUBECONFIG="${HOME}/.kube/config"

echo "Get cluster info..."
kubectl cluster-info
kubectl version
echo

echo "Wait for kubernetes to be ready"
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
echo

kubectl get all --all-namespaces

# Delete kind cluster.
kind delete cluster
