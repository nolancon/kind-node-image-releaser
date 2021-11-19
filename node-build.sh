#!/bin/bash

set -Eeuxo pipefail

: ${K8S_GIT_REPO_BRANCH?= require}
: ${KIND_GIT_REPO:-github.com/kubernetes-sigs/kind}
: ${KIND_GIT_REPO_BRANCH:-main}

KIND_IMPORT_PATH=sigs.k8s.io/kind
KIND_GIT_REPO_DIR=$GOPATH/src/$KIND_IMPORT_PATH

if [[ -d "$KIND_GIT_REPO_DIR" ]]; then
    echo "Updating kind repository..."
    (cd "$KIND_GIT_REPO_DIR" ; git fetch -a ; git reset --hard origin/$KIND_GIT_REPO_BRANCH)
else
    git clone --branch "$KIND_GIT_REPO_BRANCH" https://"$KIND_GIT_REPO" "$KIND_GIT_REPO_DIR" --depth 1
fi

echo "Building kind..."
pushd "$KIND_GIT_REPO_DIR"
    go mod vendor
    go install -v $KIND_IMPORT_PATH
popd

echo "Checking the installed kind..."
kind --version

echo "Customize base image"
if [[ -f $KIND_GIT_REPO_DIR/images/base/entrypoint ]]; then
    sed -i 's|# mount -o remount,ro /sys|mount --make-shared /sys|' $KIND_GIT_REPO_DIR/images/base/entrypoint
    echo "Building kind base image..."
    kind build base-image
elif [[ -f $KIND_GIT_REPO_DIR/images/base/files/usr/local/bin/entrypoint ]]; then
    basePath=$PWD
    (cd $KIND_GIT_REPO_DIR ; git apply $basePath/entrypoint.patch)
    echo "Building kind base image..."
    (cd $KIND_GIT_REPO_DIR/images/base ; TAG=latest make quick)
fi

echo "Building kind node image from new build k/k $K8S_GIT_REPO_BRANCH..."
kind build node-image --base-image kindest/base:latest --image kindest/node:latest
