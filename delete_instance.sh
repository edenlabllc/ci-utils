#!/bin/bash
until gcloud container node-pools delete ehealth-build-${BUILD_NUMBER} --zone=europe-west1-d --cluster=dev --quiet;
do
    sleep 22
done
