#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    if [ "$TRAVIS_BRANCH" == "develop" ]; then
        curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella/wait-for-deployment.sh -o wait-for-deployment.sh

        ## install kubectl
        # curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
        # chmod +x ./kubectl
        # sudo mv ./kubectl /usr/local/bin/kubectl
        ## Install helm
        # curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
        # chmod 700 get_helm.sh
        # ./get_helm.sh
        # Credentials to GCE
        # gcloud auth activate-service-account --key-file=$TRAVIS_BUILD_DIR/eHealth-8110bd102a69.json
        # gcloud container clusters get-credentials dev --zone europe-west1-d --project ehealth-162117
        # #get helm charts
        # git clone https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.charts.git
        # cd ehealth.charts
        # get version and project name
			# sed -i'' -e "1,10s/tag:.*/tag: \"$NEXT_VERSION\"/g" "$Chart/values.yaml"
        # helm init --upgrade
        # sleep 15
        APPS_LIST=$(echo ${APPS} | jq -r '.[]');
        for chart in ${APPS_LIST}
        do
            echo "helm upgrade -f $chart/values.yaml $chart $chart"
            # helm upgrade -f $chart/values.yaml $chart $chart
            # $TRAVIS_BUILD_DIR/bin/wait-for-deployment.sh api $chart 180
            #     if [ "$?" -eq 0 ]; then
            #         kubectl get pod -n$chart | grep api
            #         cd $TRAVIS_BUILD_DIR/ehealth.charts && git add . && sudo  git commit -m "Bump $chart api to $NEXT_VERSION" && sudo git pull && sudo git push
            #         exit 0;
            #     else
            #         kubectl logs $(sudo kubectl get pod -n$chart | awk '{ print $1 }' | grep api) -n$chart
            #         helm rollback $chart  $(($(helm ls | grep $chart | awk '{ print $2 }') -1))
            #         exit 1;
            #     fi;
        done

    fi;
fi;
