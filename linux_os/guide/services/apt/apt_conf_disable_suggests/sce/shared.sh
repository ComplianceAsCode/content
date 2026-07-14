#!/bin/sh

result=$XCCDF_RESULT_FAIL

eval `apt-config shell OPT APT::Install-Suggests`

if [ x$OPT = x0 ]; then
    result=$XCCDF_RESULT_PASS
fi

exit $result
