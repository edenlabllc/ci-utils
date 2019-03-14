#!/bin/bash
set -x
until gcloud container node-pools create $PROJECT_NAME-$BUILD_ID-$RD_CROP --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME-$BUILD_ID-$RD_CROP --node-labels=node=$PROJECT_NAME-$BUILD_ID-$RD_CROP --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
