#!/bin/bash

set -Eeuxo pipefail

: ${K8S_GIT_REPO_BRANCH?= require}
: ${K8S_VERSION?= require}

K8S_IMPORT_PATH=k8s.io/kubernetes
K8S_GIT_REPO_DIR=$GOPATH/src/$K8S_IMPORT_PATH

# k8s uses rsync in the build process.
sudo apt-get install rsync -y

# Do not shallow clone k/k. For building kind node image, git history is needed.
if [[ -d "$K8S_GIT_REPO_DIR" ]]; then
    echo "Updating k8s repository..."
    (cd "$K8S_GIT_REPO_DIR" ; git fetch -a && git reset --hard origin/$K8S_GIT_REPO_BRANCH)
else
    git clone --branch "$K8S_GIT_REPO_BRANCH" https://github.com/kubernetes/kubernetes "$K8S_GIT_REPO_DIR"
fi

(cd $K8S_GIT_REPO_DIR ; git checkout v$K8S_VERSION)
