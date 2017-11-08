#!/bin/bash
# Check if VERSION_ERROR variable was set and raise and error

if [ -n "${VERSION_ERROR+set}" ]; then
  echo $VERSION_ERROR
  exit 1
fi;