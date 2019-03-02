#!/bin/bash
set -x
until gcloud container node-pools create $PROJECT_NAME-$JOB_BASE_NAME-${RD:0:10} --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME-$JOB_BASE_NAME-${RD:0:10}:NoSchedule --node-labels=node=$PROJECT_NAME-$JOB_BASE_NAME-${RD:0:10} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
