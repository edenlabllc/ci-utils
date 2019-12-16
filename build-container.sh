#!/bin/bash
# This script builds an image based on a Dockerfile that is located in root of git working tree.
export GIT_BRANCH=${GITHUB_REF##*/}

set -e

echo "Current branch: ${GIT_BRANCH}";

for row in $(echo "${APPS}" | jq -c '.[]'); do
    APP_NAME=$(echo "${row}" | jq -r '.app')
    DOCKERFILE=$(echo "${row}" | jq -r 'if .dockerfile then .dockerfile else "Dockerfile" end')

    echo "[I] Building a Docker container for '$APP_NAME' application";
    echo "DOCKER_BUILDKIT=1 docker build --ssh default --tag \"${DOCKER_NAMESPACE}/$APP_NAME:$GITHUB_SHA\""
    echo "    --file \"${GITHUB_WORKSPACE}/${DOCKERFILE}\""
    echo "    --build-arg APP_NAME=$APP_NAME"
    echo "    \"$GITHUB_WORKSPACE\""

     DOCKER_BUILDKIT=1 sudo docker build --ssh default --tag "${DOCKER_NAMESPACE}/$APP_NAME:$GITHUB_SHA" \
            --file "${GITHUB_WORKSPACE}/${DOCKERFILE}" \
            --build-arg APP_NAME=$APP_NAME \
            "$GITHUB_WORKSPACE";
    echo
done
