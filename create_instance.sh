#!/bin/bash
set -x
until gcloud container node-pools create ${PROJECT_NAME}-${GIT_COMMIT:0:7}-${BUILD_NUMBER} --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=${BUILD_TAG}:NoSchedule --node-labels=node=${BUILD_TAG} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
