#!/bin/bash
set -x
until gcloud container node-pools create $PROJECT_NAME-$BUILD_ID --cluster=dev --machine-type=${INSTANCE_TYPE} --image-type=ubuntu --node-taints=ci=$RD_CROP:NoSchedule --node-labels=node=$RD_CROP --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
