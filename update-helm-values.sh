#!/bin/bash

# set username, password, and organization
ORG="edenlabllc"
UNAME="cube13"
UPASS=""

#echo "---"
if [[ -z "$LOG_FILE" ]]; then LOG_FILE="${VALUES}-$(date +%Y%m%d).log"; fi
if [ -f "$LOG_FILE" ]; then false; touch $LOG_FILE; else true; fi

if [[ -z "$REGISTRY_TYPE" ]]; then REGISTRY_TYPE="public"; fi
if [[ -z "$PROJECT_DIR" ]]; then PROJECT_DIR=$(pwd); fi 

# -------

set -e

if [[ $REGISTRY_TYPE == "private" ]]; then
    # get token
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
    # get list of repositories
    LAST_IMAGE_TAG=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${APP}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort -V| tail -1)
else
    LAST_IMAGE_TAG=$(curl -s https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${APP}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort -V| tail -1)
fi

echo "[I] $APP:$LAST_IMAGE_TAG"
echo "- update in $APP -> '${LAST_IMAGE_TAG}'" >> $LOG_FILE

echo "[D] sed -i '/${ORG}\/${APP}/{n;s/tag.*/tag: \"${LAST_IMAGE_TAG}\"/g;}' ./${HELM_CHART}/${VALUES}.yaml"
sed -i.bak "/${ORG}\/${APP}$/{n;s/tag.*/tag: \"${LAST_IMAGE_TAG}\"/g;}" ./${HELM_CHART}/${VALUES}.yaml
rm ./${HELM_CHART}/${VALUES}.yaml.bak

#echo "[D] sed -i.bo '/${ORG}\/${APP}/{n;s/tag.*/tag: \"${LAST_IMAGE_TAG}\"/g;}' ./${HELM_CHART}/values-demo.yaml"
#sed -i.bo "/${ORG}\/${APP}$/{n;s/tag.*/tag: \"${LAST_IMAGE_TAG}\"/g;}" ./${HELM_CHART}/values-demo.yaml
