#!/bin/bash
# check-import = stdout
# platform = Red Hat Enterprise Linux 9
if [[ $(getenforce) == "Enforcing" ]] ; then
    exit "$XCCDF_RESULT_PASS"
fi
exit "$XCCDF_RESULT_FAIL"
