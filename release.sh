#!/bin/bash

echo "[I] Building a Docker container '${APP}' from path '${PROJECT_DIR}'..";
echo "docker build --tag "${DOCKER_NAMESPACE}/${APP}:${VERSION}" --build-arg APP_NAME=$APP .;"

docker build --tag "${DOCKER_NAMESPACE}/${APP}:${VERSION}" --build-arg APP_NAME=$APP .;

echo "[I] Pushing changes to Docker Hub.."
echo "docker push \"${DOCKER_NAMESPACE}/${APP}:${VERSION}\""
docker push "${DOCKER_NAMESPACE}/${APP}:${VERSION}"

echo "[I] Creating git tag.."
echo "git tag ${VERSION}"
git tag ${VERSION}

echo "[I] Pushing tag.."
git push ${VERSION}

echo
