#!/bin/bash
set -e

export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD};

# Get latest version
echo "Retrieving token ...";
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_HUB_LOGIN}'", "password": "'${DOCKER_HUB_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token);

export TOKEN=${TOKEN};
