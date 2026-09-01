#!/usr/bin/env bash
# platform = multi_platform_rhel,multi_platform_fedora,Oracle Linux 8,Oracle Linux 9
# check-import = stdout

update-crypto-policies --check
rc=$?

if [ $rc -eq 0 ]; then
    exit "${XCCDF_RESULT_PASS}"
fi

exit "${XCCDF_RESULT_FAIL}"
