#!/bin/bash
export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD};

if [ - z "$CHANGE_ID" ]; then
    if [ "$GIT_BRANCH" == "develop" ]; then
        curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/wait-for-deployment.sh -o wait-for-deployment.sh
        chmod 700 ./wait-for-deployment.sh

        i=0
        APPS_LIST=$(echo ${APPS} | jq -r '.[].chart');
        for chart in ${APPS_LIST}
        do
            namespace=$(echo ${APPS} | jq -r ".[$i].namespace");
            deployment=$(echo ${APPS} | jq -r ".[$i].deployment");
            label=$(echo ${APPS} | jq -r ".[$i].label");
            # echo "helm upgrade -f $chart/values-dev.yaml $chart $chart"
            # helm upgrade -f $chart/values-dev.yaml $chart $chart

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
    else
    echo 'Not a develop branch'
    fi;
else echo "it's a PR" 
fi;
