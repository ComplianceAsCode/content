#!/bin/bash
# platform = multi_platform_debian,multi_platform_sle,multi_platform_ubuntu
# check-import = stdout

# Fallback values in case the calling engine does not export XCCDF_RESULT_* variables
: "${XCCDF_RESULT_PASS:=101}"
: "${XCCDF_RESULT_FAIL:=102}"

# If apparmor or apparmor-utils are not installed, then this test fails.
{{{ bash_package_installed("apparmor") }}}
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

# if number of apparmor profiles loaded not the same as enforced profiles, then it fails.
loaded_profiles=$(/usr/sbin/aa-status --profiled 2>/dev/null | grep -oE '^[0-9]+$')
enforced_profiles=$(/usr/sbin/aa-status --enforced 2>/dev/null | grep -oE '^[0-9]+$')
if [ "${loaded_profiles:-0}" -ne "${enforced_profiles:-0}" ]; then
    exit $XCCDF_RESULT_FAIL
fi

unconfined=$(/usr/sbin/aa-status 2>/dev/null | grep "processes are unconfined" | awk '{print $1;}')
if [ "${unconfined:-0}" -ne 0 ]; then
    exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS
