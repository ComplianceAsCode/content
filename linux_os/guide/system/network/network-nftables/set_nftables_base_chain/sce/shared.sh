#!/bin/bash
# platform = multi_platform_all
# check-import = stdout

output=$(nft list ruleset)
# Check if there are base chains
if ! (grep -q 'hook input' "$output" &&\
    grep -q 'hook forward' "$output" &&\
    grep -q 'hook output' "$output"); then
    exit "${XCCDF_RESULT_FAIL}"
fi

exit "${XCCDF_RESULT_PASS}"
