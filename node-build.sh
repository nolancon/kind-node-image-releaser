#!/bin/bash

set -Eeuxo pipefail

# k8s repo version to build the kind node image from.
K8S_REPO_VERSION="${K8S_REPO_VERSION:-master}"
# Container image repo name to be used for the kind node image.
KIND_NODE_IMAGE_REPO="${KIND_NODE_IMAGE_REPO:-kindest/node}"
# Tag of the kind node image. 
KIND_NODE_IMAGE_TAG="${KIND_NODE_IMAGE_TAG:-test}"
# KinD git repo to build custom version of kind.
KIND_GIT_REPO="${KIND_GIT_REPO:-github.com/kubernetes-sigs/kind}"
# KinD git repo branch to build custom version of kind.
KIND_GIT_REPO_BRANCH="${KIND_GIT_REPO_BRANCH:-main}"


build_kind() {
    KIND_IMPORT_PATH=sigs.k8s.io/kind
    KIND_GIT_REPO_DIR=$GOPATH/src/$KIND_IMPORT_PATH

    echo "Cloning kind repo..."
    if [[ -d "$KIND_GIT_REPO_DIR" ]]; then
        (cd "$KIND_GIT_REPO_DIR" ; git fetch -a ; git reset --hard origin/$KIND_GIT_REPO_BRANCH)
    else
        git clone --branch "$KIND_GIT_REPO_BRANCH" --single-branch https://"$KIND_GIT_REPO" "$KIND_GIT_REPO_DIR" --depth 1
    fi

    echo "Building kind..."
    pushd "$KIND_GIT_REPO_DIR"
        go mod vendor
        go install -v $KIND_IMPORT_PATH
    popd

    echo "Checking the installed kind..."
    kind --version
}

build_kind_node() {
    echo "Customize base image"
    if [[ -f $KIND_GIT_REPO_DIR/images/base/entrypoint ]]; then
        sed -i 's|# mount -o remount,ro /sys|mount --make-shared /sys|' $KIND_GIT_REPO_DIR/images/base/entrypoint
        echo "Building kind base image..."
        kind build base-image
    elif [[ -f $KIND_GIT_REPO_DIR/images/base/files/usr/local/bin/entrypoint ]]; then
        basePath=$PWD
        (cd $KIND_GIT_REPO_DIR ; git apply $basePath/entrypoint.patch)
        echo "Building kind base image..."
        (cd $KIND_GIT_REPO_DIR/images/base ; make quick)
    fi
    
    echo "Base image"
    docker images | grep "kindest/base"

    echo "Building kind node image from new build k/k $K8S_REPO_VERSION..."
    kind build node-image --base-image kindest/base:$(docker images | grep "kindest/base" | head -1 | awk '{print $2}') --image "$KIND_NODE_IMAGE_REPO:$KIND_NODE_IMAGE_TAG"
}

# Run a kind cluster and check if it's ready.
run_kind() {
    sudo cp "$GOPATH/src/k8s.io/kubernetes/_output/dockerized/bin/linux/amd64/kubectl" /usr/local/bin/

    echo "Create Kubernetes cluster with kind..."
    kind create cluster --image "$KIND_NODE_IMAGE_REPO:$KIND_NODE_IMAGE_TAG"
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
}

main() {
    build_kind
    build_kind_node
    run_kind
}

main
