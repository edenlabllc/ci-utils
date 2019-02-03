#!/bin/bash
export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD};

if [ - z "$CHANGE_ID" == "true" ]; then
    if [ "$GIT_BRANCH" == "develop" ]; then
        curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_v2/wait-for-deployment.sh -o wait-for-deployment.sh
        chmod 700 ./wait-for-deployment.sh

        # install kubectl
        curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        ## Install helm
        curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
        chmod 700 get_helm.sh
        ./get_helm.sh
        # Credentials to GCE
        gcloud auth activate-service-account --key-file=$TRAVIS_BUILD_DIR/eHealth-8110bd102a69.json
        gcloud container clusters get-credentials dev --zone europe-west1-d --project ehealth-162117
        #get helm charts
        git clone https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.charts.git
        cd ehealth.charts

        i=0
        APPS_LIST=$(echo ${APPS} | jq -r '.[].chart');
        for chart in ${APPS_LIST}
        do
            namespace=$(echo ${APPS} | jq -r ".[$i].namespace");
            deployment=$(echo ${APPS} | jq -r ".[$i].deployment");
            label=$(echo ${APPS} | jq -r ".[$i].label");
            echo "helm upgrade -f $chart/values-dev.yaml $chart $chart"
            helm upgrade -f $chart/values-dev.yaml $chart $chart

            if [ "$label" != "null" ]; then 
                echo "kubectl delete pod -l app=$label -n $namespace"
                kubectl delete pod -l app=$label -n $namespace
                $TRAVIS_BUILD_DIR/wait-for-deployment.sh $deployment $namespace 180
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
