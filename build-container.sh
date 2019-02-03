#!/bin/bash

export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD};

# This script builds an image based on a Dockerfile that is located in root of git working tree.
set -e

echo "Current branch: ${TRAVIS_BRANCH}";

for row in $(echo "${APPS}" | jq -c '.[]'); do
    APP_NAME=$(echo "${row}" | jq -r '.app')
    DOCKERFILE=$(echo "${row}" | jq -r 'if .dockerfile then .dockerfile else "Dockerfile" end')

    echo "[I] Building a Docker container for '$APP_NAME' application";
    echo "docker build --tag \"${DOCKER_NAMESPACE}/$APP_NAME:develop\""
    echo "    --file \"${PROJECT_DIR}/${DOCKERFILE}\""
    echo "    --build-arg APP_NAME=$APP_NAME"
    echo "    \"$PROJECT_DIR\""
    
     docker build --tag "${DOCKER_NAMESPACE}/$APP_NAME:develop" \
            --file "${PROJECT_DIR}/${DOCKERFILE}" \
            --build-arg APP_NAME=$APP_NAME \
            "$PROJECT_DIR";

    echo
done
