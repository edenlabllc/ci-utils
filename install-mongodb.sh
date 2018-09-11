#!/bin/bash

MONGODB_VERSION="4.0.1"

wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGODB_VERSION}.tgz -O /tmp/mongodb.tgz
tar -xvf /tmp/mongodb.tgz
mkdir /tmp/data

${PWD}/mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod --bind_ip 0.0.0.0 --dbpath /tmp/data &> /dev/null &
