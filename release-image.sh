#!/bin/bash

: ${K8S_VERSION?= require}
: ${KIND_NODE_IMAGE_REPO?= require}

docker tag kindest/node:latest "$KIND_NODE_IMAGE_REPO:$K8S_VERSION"
docker push "$KIND_NODE_IMAGE_REPO:v$K8S_VERSION"
