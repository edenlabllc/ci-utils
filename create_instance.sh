#!/bin/bash
for ((i = 1; i < 11; i++))
do 
    gcloud container node-pools create ehealth-build-${BUILD_NUMBER} --cluster=dev --machine-type=n1-highcpu-16 --node-taints=ci=${BUILD_TAG}:NoSchedule --node-labels=node=${BUILD_TAG} --num-nodes=1 --zone=europe-west1-d --preemptible
        if [ $? -ne 0 ]; then
            sleep 25
            if [ $i -eq 10 ]; then
                echo could not create instance
                exit 1
            fi  
        else
            break
        fi
done
