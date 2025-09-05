#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

# Check if default policy is drop
output=$(nft list ruleset)

if ! (grep 'hook input' "$output" |& grep -w 'policy drop' &>/dev/null &&\
     grep 'hook forward' "$output" |&  grep -w 'policy drop' &>/dev/null &&\
     grep 'hook output' "$output" |& grep -w 'policy drop' &>/dev/null); then
    exit "${XCCDF_RESULT_FAIL}"
fi

exit "${XCCDF_RESULT_PASS}"
