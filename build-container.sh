#!/bin/bash
# This script builds an image based on a Dockerfile that is located in root of git working tree.
set -e

echo "Current branch: ${TRAVIS_BRANCH}";

APPS_LIST=$(echo ${APPS} | jq -r 'keys[]');
for i in ${APPS_LIST}
do
    echo "[I] Building a Docker container '${i}' from path '${PROJECT_DIR}'..";
    echo "docker build --tag \"${DOCKER_NAMESPACE}/${i}:develop\""
    echo "    --file \"${PROJECT_DIR}/Dockerfile\""
    echo "    --build-arg APP_NAME=$i"
    echo "    \"$PROJECT_DIR\""

    docker build --tag "${DOCKER_NAMESPACE}/${i}:develop" \
            --file "${PROJECT_DIR}/Dockerfile" \
            --build-arg APP_NAME=$i \
            "$PROJECT_DIR";

    echo
done
