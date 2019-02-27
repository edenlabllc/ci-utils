#!/bin/bash
set -x
until gcloud container node-pools create ${PROJECT_NAME}-${BRANCH_NAME}-${BUILD_ID} --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=${PROJECT_NAME}-${BRANCH_NAME}-${BUILD_ID}:NoSchedule --node-labels=node=${PROJECT_NAME}-${BRANCH_NAME}-${BUILD_ID} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
