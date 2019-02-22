#!/bin/bash
echo "------start script-----"
until gcloud container node-pools delete ehealth-build-${BUILD_NUMBER} --zone=europe-west1-d --cluster=dev --quiet;
do
    sleep 3
    echo "there are no file ff" 
    if  grep -q "Not found"; then
        echo "We found error ERROR: (gcloud.container.node-pools.delete) ResponseError: code=404, message=Not found: node pool"
        break
    fi  
done