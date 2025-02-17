#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_debian
# check-import = stdout

# Check if default policy is drop
output=$(nft list ruleset)

if ! (echo "$output" | grep 'hook input' |& grep -wq 'policy drop' &&\
     echo "$output" | grep 'hook forward' |&  grep -wq 'policy drop' &&\
     echo "$output" | grep 'hook output' |& grep -wq 'policy drop'); then
    exit "${XCCDF_RESULT_FAIL}"
fi

exit "${XCCDF_RESULT_PASS}"
