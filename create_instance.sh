#!/bin/bash
set -x
until gcloud container node-pools create ${RD} --cluster=dev --machine-type=${INSTANCE_TYPE} --node-taints=ci=${RD}:NoSchedule --node-labels=node=${RD} --num-nodes=1 --zone=europe-west1-d --preemptible;
do
    sleep 22
done
