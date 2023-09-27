#!/bin/bash
# platform = multi_platform_all
# check-import = stdout

output=$(nft list ruleset)
# Check if there are base chains
if ! (echo "$output" | grep -q 'hook input' &&\
    echo "$output" | grep -q 'hook forward' &&\
    echo "$output" |grep -q 'hook output'); then
    exit "${XCCDF_RESULT_FAIL}"
fi

exit "${XCCDF_RESULT_PASS}"
