#!/bin/bash
echo "------start script-----"
until gcloud container node-pools delete ehealth-build-${BUILD_NUMBER} --zone=europe-west1-d --cluster=dev --quiet;
do
    sleep 25
    echo "there are no file ff" 
    if echo "$?" | grep -q "ERROR: (gcloud.container.node-pools.delete) ResponseError: code=404"; then
        echo "We found error ERROR: (gcloud.container.node-pools.delete) ResponseError: code=404"
        break
    fi  
done