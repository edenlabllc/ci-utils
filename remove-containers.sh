#!/bin/bash

APPS_LIST=$(echo ${APPS} | jq -r \'.[].app\');
for app in ${APPS_LIST}
do
    echo "[I] Removing docker container and image"
    echo "docker rm  "${app}""
    echo "docker rmi  "${DOCKER_NAMESPACE}/${app}:develop""
    docker rm  "${app}"
    docker rmi  "${DOCKER_NAMESPACE}/${app}:develop"
done