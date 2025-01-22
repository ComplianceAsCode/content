#!/bin/bash
# remediation = none

echo "testuser:*:1001:1001::/home/testuser:/bin/bash" > /etc/passwd
echo "testuser:!:20111:0:99999:7:::" > /etc/shadow
echo "/bin/bash" >> /etc/shells
