#!/bin/bash
echo "------start script-----"
EX=0
GIT_COMM=${GIT_COMMIT:0:7}
until [ $EX -eq 1 ] 
do
    if gcloud container node-pools delete ${PROJECT_NAME}-${GIT_COMM}-${BUILD_NUMBER}${CHANGE_ID} --zone=europe-west1-d --cluster=dev --quiet; then
        echo "Intsance deleted"
    elif gcloud container node-pools delete ${PROJECT_NAME}-${GIT_COMM}-${BUILD_NUMBER}${CHANGE_ID} --zone=europe-west1-d --cluster=dev --quiet 2>&1 | grep -q "Not found"; then
        sleep 4
        echo "Instance doesnt exist"
        EX=1
    else
        sleep 4
        echo "Try to delete instance"
    fi
done