#!/bin/bash


. ./test_functions.sh

fixture

pushd ${TEST_REPO}
${DUPLICACY} init integration-tests $TEST_STORAGE -c 1k
${DUPLICACY} add -copy default secondary integration-tests $SECONDARY_STORAGE
add_file file1
add_file file2
${DUPLICACY} backup 
${DUPLICACY} copy -from default -to secondary
add_file file3
add_file file4
${DUPLICACY} backup 
${DUPLICACY} copy -from default -to secondary
${DUPLICACY} check --files -stats -storage default
${DUPLICACY} check --files -stats -storage secondary
# Prune revisions from default storage
${DUPLICACY} -d -v -log prune -r 1-2 -exclusive -exhaustive -storage default
# Copy snapshot revisions from secondary back to default
${DUPLICACY} copy -from secondary -to default
# Check snapshot revisions again to make sure we're ok!
${DUPLICACY} check --files -stats -storage default
${DUPLICACY} check --files -stats -storage secondary
# Check for orphaned or missing chunks
${DUPLICACY} prune -exhaustive -exclusive -storage default
${DUPLICACY} prune -exhaustive -exclusive -storage secondary
popd
