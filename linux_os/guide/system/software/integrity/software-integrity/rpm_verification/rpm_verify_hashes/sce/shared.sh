#!/usr/bin/env bash
# platform = multi_platform_fedora,multi_platform_rhel
# check-import = stdout

readarray -t FILES_WITH_INCORRECT_HASHES < <(rpm -Va --noconfig | grep -E '^..5' | awk '{print $NF}' )

if (( ${#FILES_WITH_INCORRECT_HASHES[@]} > 0 )); then
    echo "Files with incorrect hashes:"
    printf '%s\n' "${FILES_WITH_INCORRECT_HASHES[@]}"
    exit "${XCCDF_RESULT_FAIL}"
fi

exit "${XCCDF_RESULT_PASS}"
