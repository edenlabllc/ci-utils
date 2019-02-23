#!/bin/bash
echo "------start script-----"
while true 
do
    sleep 4
    if gcloud container node-pools delete ${PROJECT_NAME}-${GIT_COMMIT}-${BUILD_NUMBER}${CHANGE_ID} --zone=europe-west1-d --cluster=dev --quiet 2>&1 | grep -q 'Not found'; then
        echo Instance doesnt exist
        exit 0
    fi
done