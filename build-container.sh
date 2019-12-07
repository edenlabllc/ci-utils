#!/bin/bash
# This script builds an image based on a Dockerfile that is located in root of git working tree.
set -e

echo "Current branch: ${GIT_BRANCH}";

for row in $(echo "${APPS}" | jq -c '.[]'); do
    APP_NAME=$(echo "${row}" | jq -r '.app')
    DOCKERFILE=$(echo "${row}" | jq -r 'if .dockerfile then .dockerfile else "Dockerfile" end')

    echo "[I] Building a Docker container for '$APP_NAME' application";
    echo "docker build --tag \"${DOCKER_NAMESPACE}/$APP_NAME:$GITHUB_SHA\""
    echo "    --file \"${GITHUB_WORKSPACE}/${DOCKERFILE}\""
    echo "    --build-arg APP_NAME=$APP_NAME $EXTRA_ARG"
    echo "    \"$GITHUB_WORKSPACE\""

     sudo docker build --tag "${DOCKER_NAMESPACE}/$APP_NAME:$GITHUB_SHA" \
            --file "${GITHUB_WORKSPACE}/${DOCKERFILE}" \
            --build-arg APP_NAME=$APP_NAME --build-arg SSH_PRI="$SSH_PRIVATE_KEY" --build-arg SSH_PUB="$SSH_PUB_KEY" \
            "$GITHUB_WORKSPACE";

    echo
done
