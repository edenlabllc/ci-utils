#!/bin/bash
set -x
EX=1
until [ $EX -eq 0 ]
do
    if gcloud container node-pools create $PROJECT_NAME --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME:PreferNoSchedule --node-labels=node=$PROJECT_NAME --num-nodes=1 --zone=europe-west1-d --preemptible 2>&1 | grep "message=Already"; then
        sleep 4
        echo "Node already exist"
        EX=0
    else
        EX=1
        echo "second loop"
        if gcloud container node-pools create $PROJECT_NAME --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME:PreferNoSchedule --node-labels=node=$PROJECT_NAME --num-nodes=1 --zone=europe-west1-d --preemptible 2>&1 | grep "done"; then
            sleep 4
            echo "Node  exist"
            EX=0
        else
            EX=1
        fi
    fi
done