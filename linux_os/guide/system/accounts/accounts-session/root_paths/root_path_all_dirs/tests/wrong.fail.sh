#!/bin/bash
# remediation = none

echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"' > /etc/environment
rm -rf /snap
mkdir /snap
touch /snap/bin
