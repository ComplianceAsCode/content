#!/bin/bash
# remediation = none

echo "test_user:x:30090:30090:Test User:/home/test_user:/usr/bin/bash" >> /etc/passwd
echo "test_user_2:x:30090:30090:Test User 2:/home/test_user_2:/usr/bin/bash" >> /etc/passwd
