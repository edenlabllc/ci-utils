#!/bin/bash
          env;
              if [[ $BRANCH_NAME =~ ^te.* ]] ; then
                    if curl https://api.github.com/repos/edenlabllc/$REPOSITORY_NAME/pulls/$CHANGE_ID 2>/dev/null |  jq '.body' | grep -Eq '#[0-9]{1,}' ; then
                        echo "---------Correct PR and meet the requirements-------------"
                        exit 0
                    else
                      echo "---------PR does not meet the requirements-----------"
                            exit 1
                    fi
              fi
              echo "------This is ordinary commit in branch, continue CI-------"
              exit 0