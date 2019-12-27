#!/bin/bash

#set -x

if [[  -z "${CHANGE_ID}" && "${GIT_BRANCH}" == "develop" ]]; then
    echo "Logging in into Docker Hub";
    echo ${DOCKER_PASSWORD} | sudo docker login -u ${DOCKER_USERNAME} --password-stdin

    if [ ! $DOCKER_USERNAME ]; then
        echo "[E] You need to specify Docker Hub account"
        exit 1
    fi

    APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
    for app in ${APPS_LIST}
    do
        echo "[I] Pushing changes to Docker Hub.."
        echo "docker tag \"${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT\" \"${DOCKER_NAMESPACE}/${app}:develop\""
        echo "docker push \"${DOCKER_NAMESPACE}/${app}:develop\""
        echo "docker rmi \"${DOCKER_NAMESPACE}/${app}:develop\""
        sudo docker tag "${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT" "${DOCKER_NAMESPACE}/${app}:develop"
        sudo docker push "${DOCKER_NAMESPACE}/${app}:develop"
        sudo docker rmi "${DOCKER_NAMESPACE}/${app}:develop"
    done

elif [[  -z "${CHANGE_ID}" && "${GIT_BRANCH}" == "master" ]]; then
    echo "This is master. Hello Master!"
    echo "Logging in into Docker Hub";
    echo ${DOCKER_PASSWORD} | sudo docker login -u ${DOCKER_USERNAME} --password-stdin

    if [ ! $DOCKER_USERNAME ]; then
        echo "[E] You need to specify Docker Hub account"
        exit 1
    fi

    APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
    for app in ${APPS_LIST}
    do
        LAST_IMAGE_TAG=$(curl -s https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${app}/tags/?page_size=100 | jq -r '.results|.[]|.name'| sed '/[[:alpha:]]/d' | sort -V| tail -1)
        LAST_IMAGE_UPDATE=$(curl -s https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${app}/tags/${LAST_IMAGE_TAG}/ | jq -r '.last_updated')
        echo "Last builded image from $GIT_BRANCH $DOCKER_NAMESPACE/$app:$LAST_IMAGE_TAG at $LAST_IMAGE_UPDATE"
        echo "Let's see what is happend from last build"
        git log --oneline --since=${LAST_IMAGE_UPDATE}| sed 's/^ \+/&HEAD~/'
        echo "------------------------"
        echo ${LAST_IMAGE_UPDATE}
        LAST_MAJOR=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $1}' )
        LAST_MINOR=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $2}' )
        LAST_PATCH=$(echo ${LAST_IMAGE_TAG} | awk -F. '{print $3}' )

        MINOR=$(git log --oneline --since=${LAST_IMAGE_UPDATE} | sed 's/^ \+/&HEAD~/' | grep feat -c)
        PATCH=$(git log --oneline --since=${LAST_IMAGE_UPDATE} | sed 's/^ \+/&HEAD~/' | grep fix -c)
        CHORE=$(git log --oneline --since=${LAST_IMAGE_UPDATE} | sed 's/^ \+/&HEAD~/' | grep chore -c)
        MAJOR=$(git log --oneline --since=${LAST_IMAGE_UPDATE} | sed 's/^ \+/&HEAD~/' | grep ! -c)

        if [ "${MAJOR}" != "0" ]; then
            echo "MAJOR"; version="major"
            NEW_MAJOR=$((${LAST_MAJOR}+1))
            NEW_MINOR=0
            NEW_PATCH=0
        elif [ "${MINOR}" != "0" ]; then
            echo "MINOR"; version="minor"
            NEW_MAJOR=${LAST_MAJOR}
            NEW_MINOR=$((${LAST_MINOR}+1))
            NEW_PATCH=0
        elif [ "${PATCH}" != "0" ]; then
            echo "PATCH"; version="patch"
            NEW_MAJOR=${LAST_MAJOR}
            NEW_MINOR=${LAST_MINOR}
            NEW_PATCH=$((${LAST_PATCH}+1))
        elif [ "${CHORE}" != "0" ]; then
            echo "PATCH"; version="patch"
            NEW_MAJOR=${LAST_MAJOR}
            NEW_MINOR=${LAST_MINOR}
            NEW_PATCH=$((${LAST_PATCH}+1))
        else echo "No change from last build in branch $GIT_BRANCH"; version="0"
        fi;

        if [ "$version" != "0" ]; then
            NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
            echo "[I] New version $DOCKER_NAMESPACE/$app:$NEW_VERSION"
            echo "[I] Now in test stage image will be taget $DOCKER_NAMESPACE/$app:$NEW_VERSION"
            echo "[I] Pushing changes to Docker Hub.."
            echo "docker tag \"${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT\" \"${DOCKER_NAMESPACE}/${app}:$NEW_VERSION\""
            echo "docker push \"${DOCKER_NAMESPACE}/${app}:$NEW_VERSION\""
            sudo docker tag "${DOCKER_NAMESPACE}/${app}:$GIT_COMMIT" "${DOCKER_NAMESPACE}/${app}:$NEW_VERSION"
            echo "docker push \"${DOCKER_NAMESPACE}/${app}:$NEW_VERSION\""
            sudo docker push "${DOCKER_NAMESPACE}/${app}:$NEW_VERSION"
            echo "[I] ---------- Bump version in charts ----------"
            git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.charts.git
            cd ehealth.charts
            APPS_LIST_CHART=$(echo ${APPS} | jq -r '.[0].chart')
            for chart in ${APPS_LIST_CHART}
            do
                if [ "$chart" == "abac-api" ]; then
                    if [ "$APPS_LIST" == "abac_api" ]; then
                        sed -i'' -e "1,4s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.abac.api.git && cd ehealth.abac.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "abac_log_consumer" ]; then
                        sed -i'' -e "5,9s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "ael" ]; then
                    if [ "$APPS_LIST" == "ael_api" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/ael.api.git && cd ael.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "blackwater" ]; then
                    if [ "$APPS_LIST" == "blackwater_api" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/blackwater.git && cd blackwater && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "ds.api" ]; then
                    if [ "$APPS_LIST" == "ds_api" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/ds.api.git && cd ds.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "synchronizer_crl" ]; then
                        sed -i'' -e "12,17s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "ocsp_service" ]; then
                        sed -i'' -e "18,23s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "edr-api" ]; then
                    if [ "$APPS_LIST" == "edr_api" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/edr_api.git && cd edr_api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "em" ]; then
                    if [ "$APPS_LIST" == "event_manager" ]; then
                        sed -i'' -e "1,4s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/event_manager.api.git && cd event_manager.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "event_manager_consumer" ]; then
                        sed -i'' -e "5,8s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "event_manager_scheduler" ]; then
                        sed -i'' -e "9,12s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "il" ]; then
                    if [ "$APPS_LIST" == "ehealth" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.api.git && cd ehealth.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "casher" ]; then
                        sed -i'' -e "18,23s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "graphql" ]; then
                        sed -i'' -e "24,29s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "edr_validations_consumer" ]; then
                        sed -i'' -e "12,17s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "ehealth_scheduler" ]; then
                        sed -i'' -e "7,12s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "jabba" ]; then
                    if [ "$APPS_LIST" == "jabba_rpc" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/jabba.git && cd jabba && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "kafka-consumer" ]; then
                    if [ "$APPS_LIST" == "ehealth_kafka_consumer" ]; then
                        sed -i'' -e "1,5s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.kafka_consumer.git && cd ehealth.kafka_consumer && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "man" ]; then
                    if [ "$APPS_LIST" == "man_api" ]; then
                        sed -i'' -e "14,17s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/man.api.git && cd man.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "medical-events-api" ]; then
                    if [ "$APPS_LIST" == "medical_events_api" ]; then
                        sed -i'' -e "5,10s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/medical_events.git && cd medical_events && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "event_consumer" ]; then
                        sed -i'' -e "1,5s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "person_consumer" ]; then
                        sed -i'' -e "10,15s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "number_generator" ]; then
                        sed -i'' -e "15,20s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "medical_events_scheduler" ]; then
                        sed -i'' -e "25,30s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "mithril" ]; then
                    if [ "$APPS_LIST" == "mithril_api" ]; then
                        sed -i'' -e "35,39s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/mithril.api.git && cd mithril.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "mithril_scheduler" ]; then
                        sed -i'' -e "40,44s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "mpi" ]; then
                    if [ "$APPS_LIST" == "mpi" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/mpi.api.git && cd mpi.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "manual_merger" ]; then
                        sed -i'' -e "27,32s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "mpi_scheduler" ]; then
                        sed -i'' -e "22,27s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "person_updates_producer" ]; then
                        sed -i'' -e "7,12s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "person_deactivator" ]; then
                        sed -i'' -e "17,22s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "deduplication" ]; then
                        sed -i'' -e "12,17s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "ops" ]; then
                    if [ "$APPS_LIST" == "ops" ]; then
                        sed -i'' -e "1,6s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/ops.api.git && cd ops.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "ops_scheduler" ]; then
                        sed -i'' -e "7,13s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "deactivate_declaration_consumer" ]; then
                        sed -i'' -e "14,18s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "reports" ]; then
                    if [ "$APPS_LIST" == "report_api" ]; then
                        sed -i'' -e "1,5s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/report.api.git && cd report.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "capitation" ]; then
                        sed -i'' -e "6,11s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    elif [ "$APPS_LIST" == "report_cache" ]; then
                        sed -i'' -e "12,16s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                elif [ "$chart" == "rpc-health-check" ]; then
                    if [ "$APPS_LIST" == "rpc_health_check" ]; then
                        sed -i'' -e "1,5s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/rpc_health_check.git && cd rpc_health_check && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "uaddresses" ]; then
                    if [ "$APPS_LIST" == "uaddresses_api" ]; then
                        sed -i'' -e "23,29s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/uaddresses.api.git && cd uaddresses.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    fi
                elif [ "$chart" == "verification" ]; then
                    if [ "$APPS_LIST" == "otp_verification_api" ]; then
                        sed -i'' -e "1,7s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                        cd $WORKSPACE && git clone -b master --single-branch https://$GITHUB_TOKEN@github.com/edenlabllc/otp_verification.api.git && cd otp_verification.api && git checkout -b release_$NEW_VERSION && git push origin release_$NEW_VERSION
                    elif [ "$APPS_LIST" == "otp_verification_scheduler" ]; then
                        sed -i'' -e "8,12s/tag:.*/tag: \"$NEW_VERSION\"/" "$chart/values-demo.yaml"
                        git add $chart/values-demo.yaml && git commit -m "bump $chart/$APPS_LIST to $NEW_VERSION" && git push origin master && cd .. && rm -rf ehealth.charts || true
                    fi
                fi
            done
            exit 0;
        else echo "Nothing todo."
        fi;
    done


elif [[  -z "${CHANGE_ID}" && "${GIT_BRANCH}" =~ ^(test.*)$ ]]; then
    echo "This is ${GIT_BRANCH} for testing new feater. This branch building to image and will be push with tag ${GIT_BRANCH} and deploy to dev"

else
    echo "This is ${GIT_BRANCH}. Nothing to do"
fi;
