#!/bin/bash
# remediation = none

echo "testuser:x:8000:8000:testuser:/home/testuser:/bin/dash" > /etc/passwd
echo "/bin/bash" > /etc/shells
