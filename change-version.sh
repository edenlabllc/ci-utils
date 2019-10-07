#!/bin/bash
sed -i'' -e "$TAG_POSITION/tag:.*/tag: \"$PROJECT_VERSION\"/" "$CHART/$CHART_PATH"
