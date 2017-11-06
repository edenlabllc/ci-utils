#!/bin/bash
# This script can check if a local Docker container with created image started succesfully.

RUNNING_CONTAINERS=$(docker ps | wc -l | tr -d '[:space:]');

if [ $RUNNING_CONTAINERS == "1" ]; then
  echo "[E] Container is not started\!";
  docker logs ${PROJECT_NAME} --details --since 5h;
  exit 1;
fi;
