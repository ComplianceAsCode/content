#!/bin/bash
# remediation = none

echo "newuser:x:8000:8000:newuser:/home/newuser:/bin/invalid_shell" >> /etc/passwd
echo "/bin/someothershell" > /etc/shells
