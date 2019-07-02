#!/bin/bash

# set username, password, and organization
ORG="edenlabllc"
UNAME="cube13"
UPASS=""

if [[ -z "$LOG_FILE" ]]; then LOG_FILE="$(date +%Y%m%d).log"; fi
if [ -f "$LOG_FILE" ]; then echo "[I] $LOG_FILE exist"; touch $LOG_FILE; else echo "[I] $LOG_FILE created"; fi

if [[ -z "$REGISTRY_TYPE" ]]; then REGISTRY_TYPE="public"; fi
if [[ -z "$PROJECT_DIR" ]]; then PROJECT_DIR=$(pwd); fi 

# -------

set -e
echo "---"
date +%H:%M:%S 
date +%H:%M:%S >> $LOG_FILE 

if [[ $REGISTRY_TYPE == "private" ]]; then
    # get token
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
    # get list of repositories
    LAST_IMAGE_TAG=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${APP}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort | tail -1)
else
    LAST_IMAGE_TAG=$(curl -s https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${APP}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort | tail -1)
fi

echo "[I] Last version $LAST_IMAGE_TAG"

LAST_MAJOR=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $1}' )
LAST_MINOR=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $2}' )
LAST_PATCH=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $3}' )

case ${RELEASE_VERSION} in
     patch)      
            NEW_MAJOR=${LAST_MAJOR}
            NEW_MINOR=${LAST_MINOR}   
            NEW_PATCH=$((${LAST_PATCH}+1))
          ;;
     minor)      
            NEW_MAJOR=${LAST_MAJOR}
            NEW_MINOR=$((${LAST_MINOR}+1))   
            NEW_PATCH=0
          ;;
     major)
            NEW_MAJOR=$((${LAST_MAJOR}+1))
            NEW_MINOR=0   
            NEW_PATCH=0
          ;; 
     *)
          echo "[!!!] You must set RELEASE_VERSION on to patch|minir|major"
          echo "[!!!] You must set RELEASE_VERSION on to patch|minir|major" >> $LOG_FILE
          exit 1
          ;;
esac

VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
echo "[I] New version $DOCKER_NAMESPACE/$APP:$VERSION" 
echo "[I] Clone repo $GIT to $APP"
git clone $GIT $APP
cd $APP
git checkout master
cd ..
echo "[I] Building a Docker container '${APP}':'$VERSION' from path '${APP}'..";
echo "[D] docker build --tag "${DOCKER_NAMESPACE}/${APP}:${VERSION}" --build-arg APP_NAME=${APP} ./${APP};"
echo "[I] Start build ${DOCKER_NAMESPACE}/${APP}:${VERSION}" >> $LOG_FILE

docker build --tag "${DOCKER_NAMESPACE}/${APP}:${VERSION}" --build-arg APP_NAME=${APP} ./${APP};

echo "[I] Image ${DOCKER_NAMESPACE}/${APP}:${VERSION} buildet" 

echo "[I] Pushing changes to Docker Hub.."
echo "docker push \"${DOCKER_NAMESPACE}/${APP}:${VERSION}\""
docker push "${DOCKER_NAMESPACE}/${APP}:${VERSION}"
date +%H:%M:%S >> $LOG_FILE
rm -r -f $APP

echo "New builded image $DOCKER_NAMESPACE/$APP:$VERSION" >> $LOG_FILE

if [[ $REGISTRY_TYPE == "private" ]]; then
    # get token
    TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
    # get list of repositories
    LAST_IMAGE_TAG=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${APP}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort | tail -1)
else
    LAST_IMAGE_TAG=$(curl -s https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${APP}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort | tail -1)
fi

echo "Last actual image in docker hub $DOCKER_NAMESPACE/$APP:$LAST_IMAGE_TAG" >> $LOG_FILE

#echo "[I] Creating git tag.."
#echo "git tag ${VERSION}"
#git tag ${VERSION}

#echo "[I] Pushing tag.."
#git push origin ${VERSION}
