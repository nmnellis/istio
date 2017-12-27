#!/bin/bash

set -e

# When running docker on a Mac, root user permissions are required.
if [[ "$OSTYPE" == "darwin"* ]]; then
	USER=root
	USER_GROUP=root
else
	USER=$(id -u)
	USER_GROUP=$(id -g)
fi

[[ -z "${IMAGE_NAME}" ]] && IMAGE_NAME="istio/istio-build-ubuntu"
# The IMAGE_ID defaults to the CI hash but can be set to an arbitrary image ID (found with 'docker
# images').
[[ -z "${IMAGE_ID}" ]] && IMAGE_ID="latest"
[[ -z "${ISTIO_DOCKER_BUILD_DIR}" ]] && ISTIO_DOCKER_BUILD_DIR=/tmp/istio-docker-build
[[ -z "${ISTIO_SOURCE_DIR}" ]] && ISTIO_SOURCE_DIR=/go/src/istio.io/istio/

mkdir -p "${ISTIO_DOCKER_BUILD_DIR}"
# Since we specify an explicit hash, docker-run will pull from the remote repo if missing.
docker run --rm -t -i -u "${USER}":"${USER_GROUP}" -v "${ISTIO_DOCKER_BUILD_DIR}":/build \
	-v "/var/run/docker.sock:/var/run/docker.sock" \
  -v "$PWD":${ISTIO_SOURCE_DIR} \
	--cap-add SYS_PTRACE "${IMAGE_NAME}":"${IMAGE_ID}" \
  /bin/bash -lc "cd ${ISTIO_SOURCE_DIR} && bazel --output_base=/build build //... && bazel --output_base=/build run //mixer/docker:mixer"
