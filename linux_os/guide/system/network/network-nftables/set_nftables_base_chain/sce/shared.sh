#!/bin/bash
# platform = multi_platform_all
# check-import = stdout

chain_hook=$(nft list ruleset | grep 'hook input')
if [ -z "${chain_hook}" ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

chain_hook=$(nft list ruleset | grep 'hook forward')
if [ -z "${chain_hook}" ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

chain_hook=$(nft list ruleset | grep 'hook output')
if [ -z "${chain_hook}" ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
