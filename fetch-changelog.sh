# Build changelog
if [[ $PREVIOUS_VERSION == "0.1.0" ]]; then
  GIT_HISTORY=$(git log --no-merges --format="%B")
else
  GIT_HISTORY=$(git log --no-merges --format="%B" $PREVIOUS_VERSION..HEAD)
fi;

GIT_HISTORY_CLEANED=$(echo "${GIT_HISTORY}" | grep -v 'ci skip' | grep -v 'changelog skip' | sed 's/^* //g')
MAJOR_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '\[major\]')
MINOR_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '\[minor\]')
PATCH_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '\[patch\]')

OTHER_CHANGES=$(grep -ivo '\[major\]' <<< "${GIT_HISTORY_CLEANED}" | grep -ivo '\[minor\]' | grep -ivo '\[patch\]' | wc -l)
OTHER_CHANGES=$(expr $OTHER_CHANGES + 0)

CHANGELOG=""
if [[ "${MAJOR_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Major changes**: "$'\n'"${MAJOR_CHANGES}"$'\n\n'
fi;

if [[ "${MINOR_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Minor changes**: "$'\n'"${MINOR_CHANGES}"$'\n\n'
fi;

if [[ "${PATCH_CHANGES}" != "0" ]]; then
  CHANGELOG="${CHANGELOG}**Patches and bug fixes**: "$'\n'"${PATCH_CHANGES}"$'\n\n'
fi;

if [[ "${OTHER_CHANGES}" != "0" ]]; then
  CHANGELOG="${CHANGELOG}"$'\n'" **${OTHER_CHANGES} other** changes."
fi;

if [[ "${CHANGELOG}" == "" ]]; then
  CHANGELOG="${GIT_HISTORY_CLEANED}"
fi;

CHANGELOG="${CHANGELOG//\[major\]/}"
CHANGELOG="${CHANGELOG//\[minor\]/}"
CHANGELOG="${CHANGELOG//\[patch\]/}"

echo
echo "Changelog: "
echo -e "${CHANGELOG}"

export CHANGELOG=$CHANGELOG
