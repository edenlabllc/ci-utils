#!/bin/bash\

set -e

export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD};

if [[  -z "${CHANGE_ID}" && "${GIT_BRANCH}" == "develop" ]]; then
    echo "Logging in into Docker Hub";
    echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

    if [ ! $DOCKER_USERNAME ]; then
        echo "[E] You need to specify Docker Hub account"
        exit 1
    fi

    APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
    for app in ${APPS_LIST}
    do
        echo "[I] Pushing changes to Docker Hub.."
        echo "docker push \"${DOCKER_NAMESPACE}/${app}:develop\""
        docker push "${DOCKER_NAMESPACE}/${app}:develop"
    done
    else
      echo "not a develop branch"
      exit 1
fi;
