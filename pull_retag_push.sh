#!/bin/bash

set -x

docker pull "edenlabllc/$1:develop"
docker tag "edenlabllc/$1:develop" "edenlabllc/$1:$2-rc3"
docker push "edenlabllc/$1:$2-rc3"
