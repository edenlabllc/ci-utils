#!/usr/bin/env bash

# set username, password, and organization
UNAME="cube13"
UPASS="tiwnE9-ciqgez-burrar"
ORG="edenlabllc"
REGISTRY_TYPE=""

# -------

set -e
echo

if [[ $REGISTRY_TYPE == "private" ]]; then
    # get token
    echo "Retrieving token ..."
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
    # get list of repositories
    echo "Retrieving repository list ..."
    REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${ORG}/?page_size=100 | jq -r '.results|.[]|.name' | sort)
else
    REPO_LIST=$(curl -s https://hub.docker.com/v2/repositories/${ORG}/?page_size=100 | jq -r '.results|.[]|.name' |grep report| sort)
fi
    # output images & tags
    echo
    echo "Images and tags for organization: ${ORG}"
    echo
    for i in ${REPO_LIST}
    do
        echo "${i}:"
        # tags
        IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${ORG}/${i}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sort -V)
        for j in ${IMAGE_TAGS}
        do
            echo "  ${j}"
        done
        echo
    done
