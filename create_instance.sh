#!/bin/bash
set -x
until gcloud container node-pools create $PROJECT_NAME --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME:PreferNoSchedule --node-labels=node=$PROJECT_NAME --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
