#!/bin/bash
echo "------start script-----"
until gcloud container node-pools delete ${PROJECT_NAME}-${GIT_COMMIT:0:7}-${BUILD_NUMBER}${CHANGE_ID} --zone=europe-west1-d --cluster=dev --quiet 2>&1 | grep -q "Not found"
do
 sleep 4
done