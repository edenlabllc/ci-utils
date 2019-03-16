#!/bin/bash
set -x
EX=1
until [ $EX -eq 0 ]
do
    if gcloud container node-pools create $PROJECT_NAME --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME:PreferNoSchedule --node-labels=node=$PROJECT_NAME --num-nodes=1 --zone=europe-west1-d --preemptible 2>&1 | grep gke-dev-uaddresses |  grep "message=Already"; then
        sleep 4
        echo "Node already exist"
        EX=0
    else
        EX=1
        until gcloud container node-pools create $PROJECT_NAME-$BUILD_ID-$RD_CROP --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME-$BUILD_ID-$RD_CROP:PreferNoSchedule --node-labels=node=$PROJECT_NAME-$BUILD_ID-$RD_CROP --num-nodes=1 --zone=europe-west1-d --preemptible;
        do
            sleep 22
        done
    fi
done
