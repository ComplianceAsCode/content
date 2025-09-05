#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# remediation = none

# Removes audit argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
# the file needs to have exactly 1024 bytes. The grubenv files add a newline
# when it gets copied, hence we need to strip the last byte of the file so
# the command grub2-editenv doesn't end with "/usr/bin/grub2-editenv: error: environment block too small."
head -c -1 grubenv > "$file"
