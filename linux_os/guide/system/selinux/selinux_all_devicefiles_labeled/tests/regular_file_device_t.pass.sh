#!/bin/bash

# workaround for https://bugzilla.redhat.com/show_bug.cgi?id=2175290
# see https://github.com/ComplianceAsCode/content/issues/10232
chcon -t zero_device_t /dev/userfaultfd

touch /dev/foo
restorecon -F /dev/foo
