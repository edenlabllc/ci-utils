#!/bin/bash
# This script starts a local Docker container with created image.
# Use `-i` to start it in interactive mode (foreground console and auto-remove on exit).
# export GIT_BRANCH=${GITHUB_REF##*/}

set -e

# Get container host address
HOST_IP=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`
HOST_NAME="travis"

i=0
APPS_LIST=$(echo ${APPS} | jq -r '.[].app');
for app in ${APPS_LIST}
do
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
      echo "docker run"
      echo "    --env-file .env"
      echo "    ${OPTS} ${ARGS}"
      echo "    --add-host=$HOST_NAME:$HOST_IP"
      echo "    --name ${app}"
      echo "    -v $(pwd):/host_data"
      echo "    $app:$GITHUB_SHA"

      sudo docker run \
          --env-file .env \
          ${OPTS} ${ARGS} \
          --add-host=$HOST_NAME:$HOST_IP \
          --name ${app} \
          -v $(pwd):/host_data \
          "${DOCKER_NAMESPACE}/$app:$GITHUB_SHA"
      sleep 5
      sudo docker network ls
      sudo docker ps --all

      sudo docker logs ${app} --details --since 5h;

      IS_RUNNING=$(sudo docker inspect --format='{{ .State.Running }}' ${app});

      if [ -z "$IS_RUNNING" ] || [ $IS_RUNNING != "true" ]; then
      echo "[E] Container is not started.";
      exit 1;
      fi;

      sudo docker stop ${app}
  fi

  i=$i+1
done
