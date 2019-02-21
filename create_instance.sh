#!/bin/bash
for ((i = 0; i < 10; i++))
do 
    gcloud container node-pools create ehealth-build-${BUILD_NUMBER} --cluster=dev --machine-type=n1-highcpu-16 --node-taints=ci=${BUILD_TAG}:NoSchedule --node-labels=node=${BUILD_TAG} --num-nodes=1 --zone=europe-west1-d --preemptible || FAIL=1
    if [ $FAIL == 1 ]; then
    sleep 25
    continue
    fi

done