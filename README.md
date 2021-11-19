# kind-node-image-releaser

Release new [kubernetes-in-docker](https://github.com/kubernetes-sigs/kind) node
images.

### Environment variables

| Variable Name | Description |
| ------------- | ----------- |
| `K8S_GIT_REPO_BRANCH` | k8s branch to build kind node image from. |
| `K8S_VERSION` | k8s version to build kind node image from. |
| `KIND_NODE_IMAGE_REPO` | Container image repo name to be used for the kind node image. New images are pushed to this repo when released. |
| `KIND_GIT_REPO` | kind git repo to build kind from. Defaults to github.com/kubernetes-sigs/kind. Can be set to use a kind fork. |
| `KIND_GIT_REPO_BRANCH` | kind git repo branch to build kind from. Defaults to `main`. |

Some documentation found here: https://github.com/storageos/cluster-operator/blob/master/docs/build-kind-node-image.md