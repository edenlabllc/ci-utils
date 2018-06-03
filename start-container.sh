#!/bin/bash
# This script starts a local Docker container with created image.
# Use `-i` to start it in interactive mode (foreground console and auto-remove on exit).
set -e

# Get container host address
HOST_IP=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`
HOST_NAME="travis"

APPS_LIST=$(echo ${APPS} | jq -r '.[]');
for i in ${APPS_LIST}
do
    (cd apps/${i} && MIX_ENV=dev mix ecto.setup)
    echo "[I] Starting a Docker container '${i}' from path '${PROJECT_DIR}' and"
    echo "    adding parent host '${HOST_NAME}' with IP '${HOST_IP}'."

    # Allow to pass -i option to start container in interactive mode
    OPTS="-d"
    ARGS=""
    while getopts "ia:" opt; do
    case "$opt" in
        i)  OPTS="-it --rm"
            ;;
        a)  ARGS=$(eval "echo -ne ${OPTARG}")
    esac
    done

    echo "docker run -p 4000:4000"
    echo "    --env-file .env"
    echo "    ${OPTS} ${ARGS}"
    echo "    --add-host=$HOST_NAME:$HOST_IP"
    echo "    --name ${i}"
    echo "    -v $(pwd):/host_data"
    echo "    ${i}:develop"

    docker run -p 4000:4000 \
        --env-file .env \
        ${OPTS} ${ARGS} \
        --add-host=$HOST_NAME:$HOST_IP \
        --name ${i} \
        -v $(pwd):/host_data \
        "${i}:develop"
    sleep 5
    docker ps

    docker logs ${i} --details --since 5h;

    IS_RUNNING=$(docker inspect --format='{{ .State.Running }}' ${i});

    if [ -z "$IS_RUNNING" ] || [ $IS_RUNNING != "true" ]; then
    echo "[E] Container is not started.";
    exit 1;
    fi;
done
