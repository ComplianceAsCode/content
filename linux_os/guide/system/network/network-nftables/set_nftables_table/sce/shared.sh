#!/bin/bash
#
# platform = multi_platform_ubuntu
# check-import = stdout
#

tbl_output=$(nft list tables)
if [ -z "${tbl_output}" ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
