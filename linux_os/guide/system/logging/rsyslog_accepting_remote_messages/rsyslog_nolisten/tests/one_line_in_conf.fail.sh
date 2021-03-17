#!/bin/bash
#
# remediation = none

. shared.sh

echo "\$UDPServerRun 5000" >> "$CONF_FILE"
