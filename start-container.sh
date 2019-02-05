#!/bin/bash
# This script starts a local Docker container with created image.
# Use `-i` to start it in interactive mode (foreground console and auto-remove on exit).

set -e

export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD};

# Get container host address
# HOST_IP=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`
# HOST_NAME="travis"

i=0
APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
for app in ${APPS_LIST}
do
    if [ -z "$NO_ECTO_SETUP" ]; then
        if [ -d "apps/${app}" ]; then
            echo "(cd apps/${app} && MIX_ENV=dev mix ecto.setup)"
            (cd apps/${app} && MIX_ENV="dev mix ecto.setup")
        else
            echo "MIX_ENV=dev mix ecto.setup"
            MIX_ENV="dev mix ecto.setup"
        fi
    fi

    echo "[I] Starting a Docker container for '${app}' application and"
    echo "    adding parent host '${HOST_NAME}' with IP '${HOST_IP}'."

    # Allow to pass -i option to start container in interactive mode
    OPTS="-dt"
    ARGS=""
    while getopts "ia:" opt; do
    case "$opt" in
        i)  OPTS="-it --rm"
            ;;
        a)  ARGS=$(eval "echo -ne ${OPTARG}")
    esac
    done

    if [ ! -z "${NETWORK}" ]; then
        ARGS="${ARGS} --network=${NETWORK}"
    fi

    if [ ! -z "${DOCKER_HOSTS}" ]; then
        HOSTS_LIST=$(echo ${DOCKER_HOSTS} | jq -r '.[]');
        for j in ${HOSTS_LIST}
        do
            ARGS="${ARGS} --add-host=${j}"
        done
    fi

    job=$(echo ${APPS} | jq -r ".[$i].job");
    if [ "$job" != "true" ]; then
        echo "docker run -p 4000:4000"
        echo "    --env-file .env"
        echo "    ${OPTS} ${ARGS}"
        echo "    --name ${app}"
        echo "    -v $(pwd):/host_data"
        echo "    $app:develop"

        docker run -p 4000:4000 \
            --env-file .env \
            ${OPTS} ${ARGS} \
            --name ${app} \
            -v $(pwd):/host_data \
            "${DOCKER_NAMESPACE}/$app:develop"
        sleep 5
        docker network ls
        docker ps --all

        docker logs ${app} --details --since 5h;

        IS_RUNNING=$(docker inspect --format='{{ .State.Running }}' ${app});

        if [ -z "$IS_RUNNING" ] || [ $IS_RUNNING != "true" ]; then
        echo "[E] Container is not started.";
        exit 1;
        fi;

        docker stop ${app}
    fi

    i=$i+1
done
