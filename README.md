# kind-node-image-releaser

Release new [kubernetes-in-docker](https://github.com/kubernetes-sigs/kind) node
images.

`.travis.yml` uses `$TRAVIS_TAG` to set the `K8S_REPO_VERSION` env var. Creating
a new git tag will trigger a new build for releasing a new version of kind node
image. The tag must match with an existing kubernetes/kubernetes branch or tag.

### Environment variables

| Variable Name | Description |
| ------------- | ----------- |
| `K8S_REPO_VERSION` | k8s repo version to build kind node image from. |
| `KIND_NODE_IMAGE_REPO` | Container image repo name to be used for the kind node image. New images are pushed to this repo when released. |
| `KIND_NODE_IMAGE_TAG` | Container image tag to be used for the kind node image. This is usually the k8s version. |
| `KIND_GIT_REPO` | kind git repo to build kind from. Defaults to github.com/kubernetes-sigs/kind. Can be set to use a kind fork. |
| `KIND_GIT_REPO_BRANCH` | kind git repo branch to build kind from. Defaults to `main`. |

Some documentation found here: https://github.com/storageos/cluster-operator/blob/master/docs/build-kind-node-image.md