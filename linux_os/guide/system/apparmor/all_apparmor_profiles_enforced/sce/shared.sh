#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_debian
# check-import = stdout

# If apparmor or apparmor-utils are not installed, then this test fails.
{{{ bash_package_installed("apparmor") }}} && {{{ bash_package_installed("apparmor-utils") }}}
if [ $? -ne 0 ]; then
        exit ${XCCDF_RESULT_FAIL}
fi

# if number of apparmor profiles loaded not the same as enforced profiles, then it fails.
loaded_profiles=$(/usr/sbin/aa-status --profiled)
enforced_profiles=$(/usr/sbin/aa-status --enforced)
if [ ${loaded_profiles} -ne ${enforced_profiles} ]; then
    exit $XCCDF_RESULT_FAIL
fi

unconfined=$(/usr/sbin/aa-status | grep "processes are unconfined" | awk '{print $1;}')
if [ $unconfined -ne 0 ]; then
    exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS
