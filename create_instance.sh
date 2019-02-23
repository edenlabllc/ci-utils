#!/bin/bash
until gcloud container node-pools create ${PROJECT_NAME}-${GIT_COMMIT}-${BUILD_NUMBER}${CHANGE_ID} --cluster=dev --machine-type=n1-highcpu-16 --node-taints=ci=${BUILD_TAG}:NoSchedule --node-labels=node=${BUILD_TAG} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
