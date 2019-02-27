#!/bin/bash
set -x
until gcloud container node-pools create ${PROJECT_NAME}-${RANDOM}-${BUILD_NUMBER} --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=${RANDOM}:NoSchedule --node-labels=node=${RANDOM} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
