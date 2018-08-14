#!/bin/bash
# This script builds an image based on a Dockerfile that is located in root of git working tree.
set -e

echo "Current branch: ${TRAVIS_BRANCH}";

APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
for app in ${APPS_LIST}
do
    echo "[I] Building a Docker container for '$app' application";
    echo "docker build --tag \"${DOCKER_NAMESPACE}/$app:develop\""
    echo "    --file \"${PROJECT_DIR}/Dockerfile\""
    echo "    --build-arg APP_NAME=$app"
    echo "    \"$PROJECT_DIR\""

    docker build --tag "${DOCKER_NAMESPACE}/$app:develop" \
            --file "${PROJECT_DIR}/Dockerfile" \
            --build-arg APP_NAME=$app \
            "$PROJECT_DIR";

    echo
done
