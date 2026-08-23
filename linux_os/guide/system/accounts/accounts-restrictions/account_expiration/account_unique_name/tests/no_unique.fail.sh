#!/bin/bash
#
# remediation = none

echo "testuser:x:8000:8000:testuser:/home/testuser:/bin/bash" >> /etc/passwd
echo "testuser:x:9000:9000:testuser:/home/testuser:/bin/bash" >> /etc/passwd
