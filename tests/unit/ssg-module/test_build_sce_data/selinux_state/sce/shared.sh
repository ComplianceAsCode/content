#!/bin/bash
# check-import = stdout
if [[ $(getenforce) == "Enforcing" ]] ; then
    exit "$XCCDF_RESULT_PASS"
fi
exit "$XCCDF_RESULT_FAIL"
