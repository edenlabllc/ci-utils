#!/bin/bash
echo "------start script-----"
while true 
do
    sleep 4
    if gcloud container node-pools delete ehealth-build-${BUILD_NUMBER} --zone=europe-west1-d --cluster=dev --quiet | grep -q 'not found'; then
        echo Delete instans succesfull
        exit 0
    fi
done