#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ubuntu,multi_platform_debian
# check-import = stdout

tbl_output=$(nft list tables | grep inet)
if [ -z "${tbl_output}" ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
