#!/bin/bash
# This script can check if a local Docker container with created image started succesfully.
docker logs ${PROJECT_NAME} --details --since 5h;

IS_RUNNING=$(sudo docker inspect --format='{{ .State.Running }}' ${PROJECT_NAME});

if [ $IS_RUNNING == "false" ]; then
  echo "[E] Container is not started.";
  exit 1;
fi;

