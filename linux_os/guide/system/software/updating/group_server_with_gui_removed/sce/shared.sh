#!/usr/bin/env bash
# platform = multi_platform_rhel
# check-import = stdout

if dnf grouplist | sed -n '/Installed Environment Groups:/,/Installed Groups:/p' | grep -q "Server with GUI"; then
    echo "Server with GUI group is installed"
    exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS
