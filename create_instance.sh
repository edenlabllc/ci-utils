#!/bin/bash
set -x
until gcloud container node-pools create $PROJECT_NAME-$BUILD_ID-$NAME --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$RD_CROP:NoSchedule --node-labels=node=$RD_CROP --num-nodes=1 --zone=europe-west1-d;
do
    sleep 22
done
