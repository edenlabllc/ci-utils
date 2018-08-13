#!/bin/bash

echo "bind 0.0.0.0 ::1" >> /etc/redis/redis.conf

service redis-server stop
service redis-server start
