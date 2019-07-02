#!/bin/bash

#set -x

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

elif [[  -z "${CHANGE_ID}" && "${GIT_BRANCH}" == "master" ]]; then
    echo "This is master. Hello Master!"
    echo "Logging in into Docker Hub";
    echo ${DOCKER_PASSWORD} | sudo docker login -u ${DOCKER_USERNAME} --password-stdin

    if [ ! $DOCKER_USERNAME ]; then
        echo "[E] You need to specify Docker Hub account"
        exit 1
    fi

    APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
    for app in ${APPS_LIST}
    do
        LAST_IMAGE_TAG=$(curl -s https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${app}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort | tail -1)
        LAST_IMAGE_UPDATE=$(curl -s https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${app}/tags/${LAST_IMAGE_TAG}/ | jq -r '.last_updated')
        echo "Last builded image from $GIT_BRANCH $DOCKER_NAMESPACE/$app:$LAST_IMAGE_TAG at $LAST_IMAGE_UPDATE"
        echo "Let's see what is happend from last build"
        #git log --oneline --since=${LAST_IMAGE_UPDATE}| sed 's/^ \+/&HEAD~/'
        echo "------------------------"
        echo ${LAST_IMAGE_UPDATE}
        LAST_MAJOR=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $1}' )
        LAST_MINOR=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $2}' )
        LAST_PATCH=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $3}' )
        MINOR=$(git log --oneline --since=${LAST_IMAGE_UPDATE} | sed 's/^ \+/&HEAD~/' | grep feat -c)
        PATCH=$(git log --oneline --since=${LAST_IMAGE_UPDATE} | sed 's/^ \+/&HEAD~/' | grep fix -c)
        MAJOR=$(git log --oneline --since=${LAST_IMAGE_UPDATE} | sed 's/^ \+/&HEAD~/' | grep ! -c)
    
        if [ "${MAJOR}" != "0" ]; then 
            echo "MAJOR"; version="major"
            NEW_MAJOR=$((${LAST_MAJOR}+1))
            NEW_MINOR=0   
            NEW_PATCH=0
        elif [ "${MINOR}" != "0" ]; then 
            echo "MINOR"; version="minor"
            NEW_MAJOR=${LAST_MAJOR}
            NEW_MINOR=$((${LAST_MINOR}+1))   
            NEW_PATCH=0
        elif [ "${PATCH}" != "0" ]; then 
            echo "PATCH"; version="patch"
            NEW_MAJOR=${LAST_MAJOR}
            NEW_MINOR=${LAST_MINOR}   
            NEW_PATCH=$((${LAST_PATCH}+1))
        else echo "No change from last build in branch $GIT_BRANCH"; version="0"
        fi;
        
        if [ "$version" != "0" ]; then
            NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
            echo "[I] New version $DOCKER_NAMESPACE/$app:$NEW_VERSION" 
            echo "[I] Pushing changes to Docker Hub.."
            echo "docker tag \"${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT\" \"${DOCKER_NAMESPACE}/${app}:$NEW_VERSION\""
            echo "docker push \"${DOCKER_NAMESPACE}/${app}:$NEW_VERSION\""
            #sudo docker tag "${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT" "${DOCKER_NAMESPACE}/${app}:$NEW_VERSION"
            #sudo docker push "${DOCKER_NAMESPACE}/${app}:$NEW_VERSION"
        else echo "Nothing todo."
        fi;
    done
   

elif [[  -z "${CHANGE_ID}" && "${GIT_BRANCH}" =~ ^(test.*)$ ]]; then
    echo "This is ${GIT_BRANCH} for testing new feater. This branch building to image and will be push with tag ${GIT_BRANCH} and deploy to dev"

else
    echo "This is ${GIT_BRANCH}. Nothing to do"
fi;
