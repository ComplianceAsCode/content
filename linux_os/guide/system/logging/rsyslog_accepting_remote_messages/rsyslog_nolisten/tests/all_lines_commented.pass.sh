#!/bin/bash

. shared.sh

echo "# \$ModLoad imtcp
# \$InputTCPServerRun 5000
# \$ModLoad imudp
# \$UDPServerRun 5000
# \$ModLoad imrelp
# \$InputRELPServerRun 5000" >> "$CONF_FILE"
