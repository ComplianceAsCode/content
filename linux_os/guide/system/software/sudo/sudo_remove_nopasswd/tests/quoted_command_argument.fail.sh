#!/bin/bash
# packages = sudo

# In a command a double quote is an ordinary character and # begins a
# comment, so the next line holds an entry of its own, which stays.
mkdir -p /etc/sudoers.d
printf '%s\n' '%admin ALL=(ALL) NOPASSWD: /bin/echo "#x" \' '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/quoted
chmod 440 /etc/sudoers.d/quoted
