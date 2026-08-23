#!/bin/bash
# remediation = none

echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/nonexistent"' > /etc/environment
rm -rf /nonexistent
