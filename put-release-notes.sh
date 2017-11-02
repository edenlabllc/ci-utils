#!/bin/bash
# This script create a text file with build changelog in release_notes dir.
# Depents on env. variables set by fetch-project-environment.sh adn fetch-source-version.sh

RELEASE_NOTES_DIR="${PROJECT_DIR}/release_notes"
RELEASE_NOTES_FILE="${NEXT_VERSION}.txt"
CHANGELOG_LOG_SCRIPT="${PROJECT_DIR}/bin/ci/release/fetch-changelog.sh"

echo "[I] Creating release notes for build from '${PREVIOUS_VERSION}' to '${NEXT_VERSION}' in 'release_notes'."

if [ ! -d $RELEASE_NOTES_DIR ]; then
  mkdir $RELEASE_NOTES_DIR
fi

. $CHANGELOG_LOG_SCRIPT >> "$RELEASE_NOTES_DIR/$RELEASE_NOTES_FILE"
