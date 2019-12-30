#!/bin/bash

set -Eeuxo pipefail

K8S_REPO_VERSION="${K8S_REPO_VERSION:-master}"

# k8s uses rsync in the build process.
sudo apt-get install rsync -y

# Do not shallow clone k/k. For building kind node image, git history is needed.
git clone --branch "$K8S_REPO_VERSION" https://github.com/kubernetes/kubernetes "$GOPATH/src/k8s.io/kubernetes"
