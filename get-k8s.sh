#!/bin/bash

set -Eeuxo pipefail

K8S_REPO_VERSION="${K8S_REPO_VERSION:-master}"

# k8s uses rsync in the build process.
sudo apt-get install rsync -y

# Do not shallow clone k/k. For building kind node image, git history is needed.
if [[ -d "$GOPATH/src/k8s.io/kubernetes" ]]; then
    (cd "$GOPATH/src/k8s.io/kubernetes" ; git fetch -a ; git reset --hard origin/$K8S_REPO_VERSION)
else
    git clone --branch "$K8S_REPO_VERSION" --single-branch https://github.com/kubernetes/kubernetes "$GOPATH/src/k8s.io/kubernetes"
    lastStable=$(git log --simplify-by-decoration --pretty=oneline | egrep "v[0-9]+\.[0-9]+.[0-9]+$" | head -1 | awk '{print $6}')
    echo "Checkout $lastStable"
    (cd $GOPATH/src/k8s.io/kubernetes ; git checkout $lastStable)
fi
