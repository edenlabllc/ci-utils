#!/bin/bash

set -e


sed -i  "/${ORG}\/${APP}$/{n;s/tag.*/tag: \"${LAST_IMAGE_TAG}\"/g;}" ./ms.charts/values-staging.yaml

#echo "[D] sed -i.bo '/${ORG}\/${APP}/{n;s/tag.*/tag: \"${LAST_IMAGE_TAG}\"/g;}' ./${HELM_CHART}/values-demo.yaml"
#sed -i.bo "/${ORG}\/${APP}$/{n;s/tag.*/tag: \"${LAST_IMAGE_TAG}\"/g;}" ./${HELM_CHART}/values-demo.yaml
