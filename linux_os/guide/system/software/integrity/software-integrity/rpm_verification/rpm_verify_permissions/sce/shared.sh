#!/usr/bin/env bash
# platform = multi_platform_rhel
# check-import = stdout

readarray -t FILES_WITH_INCORRECT_PERMS < <(rpm -Va --nofiledigest | awk '{ if (substr($0,2,1)=="M") print $NF }')

if (( ${#FILES_WITH_INCORRECT_PERMS[@]} > 0 )); then
    echo "Files with incorrect perms:\n"
    printf '%s\n' "${FILES_WITH_INCORRECT_PERMS[@]}"
    exit "${XCCDF_RESULT_FAIL}"
fi

exit "${XCCDF_RESULT_PASS}"
