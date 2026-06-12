#!/bin/bash
# remediation = none

# One unlocked user with a valid shell (/bin/bash in /etc/shells)
useradd -u 8001 -s /bin/bash validuser
echo "validuser:testpass" | chpasswd

# One unlocked user with an invalid shell (not in /etc/shells)
useradd -u 8002 -s /bin/invalid_shell invaliduser
echo "invaliduser:testpass" | chpasswd

echo "/bin/bash" >> /etc/shells
