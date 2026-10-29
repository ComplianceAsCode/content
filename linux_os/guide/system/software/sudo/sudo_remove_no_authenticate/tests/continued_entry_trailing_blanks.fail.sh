#!/bin/bash
# packages = sudo

# A backslash followed only by blanks continues the entry on the next line.
mkdir -p /etc/sudoers.d
printf '%s\n' 'Defaults !authenticate, \  ' '    use_pty' > /etc/sudoers.d/continued
chmod 440 /etc/sudoers.d/continued
