#!/bin/bash
set -x
until gcloud container node-pools create ${PROJECT_NAME}-${RANDOM_VAR}-${BUILD_NUMBER} --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=${RANDOM_VAR}:NoSchedule --node-labels=node=${RANDOM_VAR} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
