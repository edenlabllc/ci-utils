#!/bin/bash
# This script create a text file with build changelog in release_notes dir.
# Depents on env. variables set by: fetch-project-environment.sh and fetch-source-version.sh

MINOR_VERSION_TEMPLATE=$(echo "${NEXT_VERSION}" | cut -d. -f1,2)'.*'
MINOR_VERSION=$(git tag -l ${MINOR_VERSION_TEMPLATE} --sort=v:refname | head -n 1)

RELEASE_NOTES_DIR="${PROJECT_DIR}/release_notes"
RELEASE_NOTES_FILE="${RELEASE_NOTES_DIR}/${MINOR_VERSION}.txt"

echo "[I] Getting release notes for ${MINOR_VERSION} - ${NEXT_VERSION}"
# Get changelog from minor ver to HEAD
if [[ $MINOR_VERSION == "0.1.0" ]]; then
  GIT_HISTORY=$(git log --no-merges --format="%B")
else
  GIT_HISTORY=$(git log --no-merges --format="%B" $MINOR_VERSION..HEAD)
fi;

GIT_HISTORY_CLEANED=$(echo "${GIT_HISTORY}" | grep -v 'ci skip' | grep -v 'changelog skip' | sed 's/^* //g')

MAJOR_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '^\[major\]' | sed 's/^\[major\]//Ig')
MAJOR_CHANGES=$(echo -e "${MAJOR_CHANGES}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') # Trim strings

MINOR_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '^\[minor\]' | sed 's/^\[minor\]//Ig')
MINOR_CHANGES=$(echo -e "${MINOR_CHANGES}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') # Trim strings

PATCH_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '^\[patch\]' | sed 's/^\[patch\]//Ig')
PATCH_CHANGES=$(echo -e "${PATCH_CHANGES}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') # Trim strings

# Remove major, minor and patch messages
OTHER_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -iv '^\[major\]' | grep -iv '^\[minor\]' | grep -iv '^\[patch\]')
# Trim strings and remove empty strings
OTHER_CHANGES=$(echo -e "${OTHER_CHANGES}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed '/^$/d')

echo "[I] Saving release notes into ${RELEASE_NOTES_FILE}"
# Save all changes notes to file
if [ ! -d $RELEASE_NOTES_DIR ]; then
  mkdir $RELEASE_NOTES_DIR
fi

CHANGELOG="Change log for versions ${MINOR_VERSION} - ${NEXT_VERSION}"$'\n\n'

if [[ "${MAJOR_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Major changes**:"$'\n\n'"${MAJOR_CHANGES}"$'\n\n'
fi;

if [[ "${MINOR_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Minor changes**:"$'\n\n'"${MINOR_CHANGES}"$'\n\n'
fi;

if [[ "${PATCH_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Patches and bug fixes**:"$'\n\n'"${PATCH_CHANGES}"$'\n\n'
fi;

if [[ "${OTHER_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Other**:"$'\n\n'"${OTHER_CHANGES}"
fi;

if [[ "${CHANGELOG}" != "" ]]; then
  echo -e "${CHANGELOG}" > $RELEASE_NOTES_FILE
fi;
