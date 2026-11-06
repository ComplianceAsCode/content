#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = autofs

SYSTEMCTL_EXEC=/usr/bin/systemctl
"$SYSTEMCTL_EXEC" stop autofs.service
"$SYSTEMCTL_EXEC" unmask autofs.service
"$SYSTEMCTL_EXEC" disable autofs.service
"$SYSTEMCTL_EXEC" reset-failed autofs.service || true
