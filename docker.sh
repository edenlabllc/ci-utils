#!/bin/bash

set -e

export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD};

curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella/init-db.sh -o init-db.sh
chmod 700 ./init-db.sh
sudo ./init-db.sh

curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella/build-container.sh -o build-container.sh
chmod 700 ./build-container.sh
./build-container.sh

curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella/start-container.sh -o start-container.sh
chmod 700 ./start-container.sh
./start-container.sh

curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella/push-changes.sh -o push-changes.sh
chmod 700 ./push-changes.sh
./push-changes.sh

curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella/autodeploy.sh -o autodeploy.sh
chmod 700 ./autodeploy.sh
./autodeploy.sh
