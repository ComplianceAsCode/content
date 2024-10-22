#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

# If apparmor or apparmor-utils are not installed, then this test fails.
{{{ bash_package_installed("apparmor") }}}
if [ $? -ne 0 ]; then
        exit ${XCCDF_RESULT_FAIL}
fi

loaded_profiles=$(/usr/sbin/aa-status --profiled)
enforced_profiles=$(/usr/sbin/aa-status --enforced)
complain=$(/usr/sbin/aa-status --complaining)
if [ ${loaded_profiles} -ne $((${enforced_profiles} + ${complain})) ]; then
    exit $XCCDF_RESULT_FAIL
fi

unconfined=$(/usr/sbin/aa-status | grep "processes are unconfined" | awk '{print $1;}')
if [ $unconfined -ne 0 ]; then
    exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS
