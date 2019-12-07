#!/bin/bash

#set -x
export GIT_BRANCH=${GITHUB_REF##*/}

if [[  $"{GIT_BRANCH}" == "develop" ]]; then
    echo "Logging in into Docker Hub";
    echo ${DOCKER_PASSWORD} | sudo docker login docker.pkg.github.com --username ${DOCKER_USERNAME} --password-stdin
    if [ ! $DOCKER_USERNAME ]; then
        echo "[E] You need to specify docker registry account"
        exit 1
    fi

    APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
    for app in ${APPS_LIST}
    do
        echo "[I] Pushing changes to Docker Hub.."
        echo "docker tag \"${DOCKER_NAMESPACE}/${app}:$GITHUB_SHA\" \"${DOCKER_NAMESPACE}/${app}:develop\""
        echo "docker push \"${DOCKER_NAMESPACE}/${app}:develop\""
        sudo docker tag "${DOCKER_NAMESPACE}/${app}:$GITHUB_SHA" "${DOCKER_NAMESPACE}/${app}:develop"
        sudo docker push "${DOCKER_NAMESPACE}/${app}:develop"
    done

else
    echo "This is ${GIT_BRANCH}. Nothing to do"
fi;
