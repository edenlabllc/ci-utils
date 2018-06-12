#!/bin/bash

echo "[I] Building a Docker container '${APP}' from path '${PROJECT_DIR}'..";
echo "docker build --tag "${DOCKER_USERNAME}/${APP}:${VERSION}" --build-arg APP_NAME=$APP .;"

docker build --tag "${DOCKER_USERNAME}/${APP}:${VERSION}" --build-arg APP_NAME=$APP .;

echo "[I] Pushing changes to Docker Hub.."
echo "docker push \"${DOCKER_USERNAME}/${APP}:${VERSION}\""
docker push "${DOCKER_USERNAME}/${APP}:${VERSION}"

echo
