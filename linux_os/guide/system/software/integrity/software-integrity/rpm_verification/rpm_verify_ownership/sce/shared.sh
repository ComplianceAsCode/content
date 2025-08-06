#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel
# check-import = stdout

readarray -t FILES_WITH_INCORRECT_OWNERSHIP < <(rpm -Va --nofiledigest | awk '{ if (substr($0,6,1)=="U" || substr($0,7,1)=="G") print $NF }')

if (( ${#FILES_WITH_INCORRECT_OWNERSHIP[@]} > 0 )); then
    echo "Files with incorrect perms:"
    printf '%s\n' "${FILES_WITH_INCORRECT_OWNERSHIP[@]}"
    exit "${XCCDF_RESULT_FAIL}"
fi

exit "${XCCDF_RESULT_PASS}"
