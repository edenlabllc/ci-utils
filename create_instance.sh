#!/bin/bash
set -x
until gcloud container node-pools create $PROJECT_NAME-$BUILD_ID-${RD:0:14} --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME-$BUILD_ID-${RD:0:14}:NoSchedule --node-labels=node=$PROJECT_NAME-$BUILD_ID-${RD:0:14} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
