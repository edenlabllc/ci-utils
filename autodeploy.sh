#!/bin/bash
set -e
rm -rf ehealth.charts || true
if [ -z "$CHANGE_ID" ]; then
    if [ "$GIT_BRANCH" == "develop" ]; then
        curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/wait-for-deployment.sh -o wait-for-deployment.sh
        chmod +x ./wait-for-deployment.sh

        # # install kubectl
        # curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
        # chmod +x ./kubectl
        # sudo mv ./kubectl /usr/local/bin/kubectl
        # ## Install helm
        # curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
        # chmod 700 get_helm.sh
        # ./get_helm.sh
        # Credentials to GCE
        gcloud auth activate-service-account --key-file=$GCLOUD_KEY
        gcloud container clusters get-credentials dev --zone europe-west1-d --project ehealth-162117
        #get helm charts
        git clone https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.charts.git
        cd ehealth.charts

        chart=$(echo ${APPS} | jq -r '.[0].chart')
        echo "helm upgrade -f $chart/values-dev.yaml $chart $chart"
        sudo helm upgrade -f $chart/values-dev.yaml $chart $chart

        i=0
        APPS_LIST=$(echo ${APPS} | jq -r '.[].chart');
        for chart in ${APPS_LIST}
        do
            namespace=$(echo ${APPS} | jq -r ".[$i].namespace");
            deployment=$(echo ${APPS} | jq -r ".[$i].deployment");
            label=$(echo ${APPS} | jq -r ".[$i].label");
            if [ "$label" != "null" ]; then 
                echo "kubectl delete pod -l app=$label -n $namespace"
                kubectl delete pod -l app=$label -n $namespace
                ../wait-for-deployment.sh $deployment $namespace 180
                    if [ "$?" -eq 0 ]; then
                        kubectl get pod -l app=$label -n $namespace
                    else
                        kubectl logs $(sudo kubectl get pod -l app=$label -n $namespace | sed -n 2p | awk '{ print $1 }') -n $namespace
                        exit 1;
                    fi;
            fi
            i=$i+1
        done
        exit 0;
    fi;
fi;