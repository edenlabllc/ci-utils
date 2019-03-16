#!/bin/bash
set -x
EX=0
until [ $EX -eq 1 ]
do
    if gcloud container node-pools create $PROJECT_NAME --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=$PROJECT_NAME:PreferNoSchedule --node-labels=node=$PROJECT_NAME --num-nodes=1 --zone=europe-west1-d --preemptible 2>&1 | grep gke-dev-uaddresses |  grep -q "message=Already exists"; then
        sleep 4
        echo "Node already exist"
        EX=1
    else
        sleep 22
        EX=0
    fi
done
