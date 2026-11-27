#!/bin/bash
# packages = sudo

# A # inside a quoted Defaults value belongs to the value, so the trailing
# backslash continues the entry on the next line.
mkdir -p /etc/sudoers.d
printf '%s\n' 'Defaults lecture_file="/etc/sudo#notice", \' '    !authenticate' > /etc/sudoers.d/quoted
chmod 440 /etc/sudoers.d/quoted
