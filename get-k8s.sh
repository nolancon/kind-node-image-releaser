#!/bin/bash

set -Eeuxo pipefail

K8S_GIT_REPO_BRANCH="${K8S_GIT_REPO_BRANCH:-master}"

# k8s uses rsync in the build process.
sudo apt-get install rsync -y

# Do not shallow clone k/k. For building kind node image, git history is needed.
if [[ -d "$GOPATH/src/k8s.io/kubernetes" ]]; then
    (cd "$GOPATH/src/k8s.io/kubernetes" ; git fetch -a ; git reset --hard origin/$K8S_GIT_REPO_BRANCH)
else
    git clone --branch "$K8S_GIT_REPO_BRANCH" --single-branch https://github.com/kubernetes/kubernetes "$GOPATH/src/k8s.io/kubernetes"
    (cd $GOPATH/src/k8s.io/kubernetes ; git checkout v$K8S_VERSION)
fi
