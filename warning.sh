#!/bin/bash

curl --header "Content-Type: application/json" \
  --request POST \
  -d \
'{
    "username":"Jenkins",
    "channel": "#ci",
    "attachments": [
        {
            "color": "warning",
            "fields": [
                {
                    "value": "Build <https://ci.asclepius.com.ua/blue/organizations/jenkins/'"$PROJECT_NAME"'/detail/'"$JOB_BASE_NAME"'/'"$BUILD_NUMBER"'/pipeline|#'"$BUILD_NUMBER"'> (<'"${GIT_URL:0:-4}"'/commit/'"$GIT_COMMIT"'|'"${GIT_COMMIT:0:7}"'>) of '"${GIT_URL:19:-4}"'@'"$GIT_BRANCH"' by '"$GIT_COMMITTER_NAME"' errored in '"$currentBuild.durationString"'m",
                    "short": false
                }
            ]
        },
    ]
}' \
https://hooks.slack.com/services/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
