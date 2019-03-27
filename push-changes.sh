#!/bin/bash

set -e

if [[  -z "${CHANGE_ID}" && "${GIT_BRANCH}" == "develop" ]]; then
    echo "Logging in into Docker Hub";
    echo ${DOCKER_PASSWORD} | sudo docker login -u ${DOCKER_USERNAME} --password-stdin

    if [ ! $DOCKER_USERNAME ]; then
        echo "[E] You need to specify Docker Hub account"
        exit 1
    fi

    APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
    for app in ${APPS_LIST}
    do
        echo "[I] Pushing changes to Docker Hub.."
        echo "docker tag \"${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT\" \"${DOCKER_NAMESPACE}/${app}:develop\""
        echo "docker push \"${DOCKER_NAMESPACE}/${app}:develop\""
        echo "docker rmi \"${DOCKER_NAMESPACE}/${app}:develop\""
        sudo docker tag "${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT" "${DOCKER_NAMESPACE}/${app}:develop"
        sudo docker push "${DOCKER_NAMESPACE}/${app}:develop"
        sudo docker rmi "${DOCKER_NAMESPACE}/${app}:develop"
    done
    else
      echo "not a develop branch"
fi;
