#!/bin/bash

cd $TRAVIS_BUILD_DIR

# Run all tests except pending ones
echo "- mix test --exclude pending --trace "
mix test --exclude pending --trace
is_failed=0;

if [ "$?" -eq 0 ]; then
  echo "mix test successfully completed"
else
  echo "mix test Finished with errors ,exited with 1"
  is_failed=1 ;
fi;

# Submit code coverage report to Coveralls
# Add --pro if you using private repo.
if [ ${COVERALLS} ]; then
  echo "- mix coveralls.travis --exclude pending --umbrella;"
        mix coveralls.travis --exclude pending --umbrella

      if [ "$?" -eq 0 ]; then
            echo "mix coveralls.travis successfully completed"
          else
            echo "mix coveralls.travis finished with errors , exited with 1"
            is_failed=1;
      fi;
fi;

# Run static code analysis
echo "- mix credo --strict ; "
mix credo --strict

if [ "$?" -eq 0 ]; then
  echo "mix credo successfully completed"
else
  echo "mix credo finished with errors, exited with 1"
  is_failed=1;
fi;

# Check code style
echo "- mix format;"
mix format --check-formatted

if [ "$?" -eq 0 ]; then
  echo "mix format successfully completed"
else
  echo "mix format finished with errors, exited with 1"
  is_failed=1;
fi;

if [ "${is_failed}" -eq 1 ]; then
  echo "finished with errors"
  exit 1;
fi;
