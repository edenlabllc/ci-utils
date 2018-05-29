export PROJECT_DIR=${TRAVIS_BUILD_DIR:=$PWD}

# Get latest version
echo "Retrieving token ..."
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_HUB_LOGIN}'", "password": "'${DOCKER_HUB_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

# get list of repositories
echo "Retrieving repository list ..."
REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${ORG}/?page_size=100 | jq -r '.results|.[]|.name')

if [[ ${TRAVIS_BRANCH} == "develop" ]]; then
  DOCKER_HUB_TAG="develop"
# elif [[ ${PATCH_CHANGES} == "0" ]]; then
#   NEXT_PATCH_VERSION=$(expr ${parts[2]} + 1)
# else
#   NEXT_PATCH_VERSION=$(expr ${parts[2]} + ${PATCH_CHANGES})
fi;


# Show version info
echo
echo "Version information: "
echo " - Next version will be ${DOCKER_HUB_TAG}"

export DOCKER_HUB_TAG=$DOCKER_HUB_TAG
