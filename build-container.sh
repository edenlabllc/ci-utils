#!/bin/bash
# This script builds an image based on a Dockerfile that is located in root of git working tree.
set -e

if [[ "${TRAVIS_BRANCH}" == "develop" ]]; then
    APPS_LIST=$(echo ${APPS} | jq -r '.[]')
    for i in ${APPS_LIST}
    do
        echo "${i}:"
        echo "[I] Building a Docker container '${i}' from path '${PROJECT_DIR}'.."
    docker build --tag "${i}:${PROJECT_VERSION}" \
                --file "${PROJECT_DIR}" \
                --build-arg APP_NAME=$i \
                "$PROJECT_DIR"

    echo
    done
fi;
