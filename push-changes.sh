#!/bin/bash

set -e

echo "Logging in into Docker Hub";
echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

if [[ "${TRAVIS_PULL_REQUEST}" == "false" && "${TRAVIS_BRANCH}" == "develop" ]]; then
    if [ ! $DOCKER_USERNAME ]; then
        echo "[E] You need to specify Docker Hub account"
        exit 1
    fi

    APPS_LIST=$(echo ${APPS} | jq -r '.[]');
    for i in ${APPS_LIST}
    do
        echo "[I] Pushing changes to Docker Hub.."
        echo "docker push \"${DOCKER_USERNAME}/${i}:develop\""
        docker push "${DOCKER_USERNAME}/${i}:develop"
    done
fi;
