#!/bin/bash

sed -i -- 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

service mongodb stop
service mongodb start
