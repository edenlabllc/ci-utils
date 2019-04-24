#!/bin/bash
if [[ $BRANCH_NAME == PR* ]] ; then
    if  curl https://api.github.com/repos/edenlabllc/$REPOSITORY_NAME/pulls/$CHANGE_ID 2>/dev/null |   jq '.base.ref' |  grep -Eq 'develop'  ; then
      if curl https://api.github.com/repos/edenlabllc/$REPOSITORY_NAME/pulls/$CHANGE_ID 2>/dev/null |  jq '.body' |  grep -Eq '#[0-9]{1,}'  ||  curl https://api.github.com/repos/edenlabllc/$REPOSITORY_NAME/pulls/$CHANGE_ID 2>/dev/null |  jq '.body' | grep -Eq 'issues/[0-9]{1,}'||  curl https://api.github.com/repos/edenlabllc/man.web/pulls/4 2>/dev/null |  jq '.body' | grep -Eq '[issue skip]' ; then
          echo "---------Correct PR that meets the requirements-------------"
          exit 0
      else
          echo "---------PR does not meet the requirements (nee)-----------"
              exit 1
      fi
    else
      echo "---------PR to the not DEVELOP branch and does not need to meet requirements -----------"
      exit 0
    fi  
fi
echo "------This is an ordinary commit in the branch, continue CI-------"
exit 0
