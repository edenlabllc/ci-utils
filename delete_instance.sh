#!/bin/bash
set -x
echo "------start script-----"
EX=0
until [ $EX -eq 1 ]
do
    if gcloud container node-pools delete ${PROJECT_NAME}-${GIT_COMMIT:0:7}-${BUILD_NUMBER}${CHANGE_ID} --zone=europe-west1-d --cluster=dev --quiet 2>&1 | grep -q "Not found"; then
        sleep 4
        echo "Instance not found"
        EX=1
    else
        sleep 4
        EX=0
    fi
done