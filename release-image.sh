#!/bin/bash

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push "$KIND_NODE_IMAGE_REPO:$KIND_NODE_IMAGE_TAG"
