#!/bin/bash
set -e

export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD}

# Get latest version
echo "Retrieving token ..."
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_HUB_LOGIN}'", "password": "'${DOCKER_HUB_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

export TOKEN=${TOKEN}
# get list of repositories
# APPS_LIST=$(echo ${APPS} | jq -r '.[]')
# for i in ${APPS_LIST}
# do
#   echo "${i}:"
#   tags
#   IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_HUB_LOGIN}/${i}/tags/?page_size=100 | jq -r '.results|.[]|.name')
#   echo ${IMAGE_TAGS}
#   echo
# done

# if [[ ${TRAVIS_BRANCH} == "develop" ]]; then
#   DOCKER_HUB_TAG="develop"
# fi;

# # Show version info
# echo
# echo "Version information: "
# echo " - Next version will be ${DOCKER_HUB_TAG}"

# export DOCKER_HUB_TAG=$DOCKER_HUB_TAG
