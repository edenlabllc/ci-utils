#!/bin/bash

export PROJECT_DIR=${WORKSPACE};

# This script builds an image based on a Dockerfile that is located in root of git working tree.
set -e

echo "Current branch: ${GIT_BRANCH}";

for row in $(echo "${APPS}" | jq -c '.[]'); do
    APP_NAME=$(echo "${row}" | jq -r '.app')
    DOCKERFILE=$(echo "${row}" | jq -r 'if .dockerfile then .dockerfile else "Dockerfile" end')

    echo "[I] Building a Docker container for '$APP_NAME' application";
    echo "docker build --tag \"${DOCKER_NAMESPACE}/$APP_NAME:$GIT_COMMIT\""
    echo "    --file \"${PROJECT_DIR}/${DOCKERFILE}\""
    echo "    --build-arg APP_NAME=$APP_NAME"
    echo "    \"$PROJECT_DIR\""
    
     sudo docker build --tag "${DOCKER_NAMESPACE}/$APP_NAME:$GIT_COMMIT" \
            --file "${PROJECT_DIR}/${DOCKERFILE}" \
            --build-arg APP_NAME=$APP_NAME \
            "$PROJECT_DIR";

    echo
done
