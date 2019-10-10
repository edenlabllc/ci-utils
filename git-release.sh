#!/bin/bash

RELEASE_VERSION=$(cat mix.exs | grep "@version" -m 1 | sed 's/[[:alpha:]]//g' | sed 's/@//g' | sed 's/ //g' | sed 's/"//g');
until git checkout -b release_$RELEASE_VERSION;
do
  if [[ $RELEASE_VERSION != *"-rc" ]]; then
    RELEASE_VERSION=$RELEASE_VERSION'-rc'
  elif [[ ${RELEASE_VERSION: -1} =~ ^-?[0-9]+$ ]]; then
    RC_VER=${RELEASE_VERSION: -1}
    RC_VER=$((RC_VER+1))
    RELEASE_VERSION=${RELEASE_VERSION::-1}
    RELEASE_VERSION=${RELEASE_VERSION}$RC_VER
  else
    RELEASE_VERSION=$RELEASE_VERSION'1'
  fi
done

git push origin release_$RELEASE_VERSION;
