#!/bin/bash
# Based on shared/templates/grub2_bootloader_argument/tests/wrong_value.fail.sh
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8

# Break the argument in kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*{{{ARG_NAME}}}=.*'  "$file" ; then
	# modify the GRUB command-line if the arg already exists
	sed -i 's/\(^.*\){{{ARG_NAME}}}=[^[:space:]]*\(.*\)/\1 {{{ARG_NAME}}}=wrong \2/'  "$file"
else
	# no arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ARG_NAME}}}=wrong/'  "$file"
fi

# Fake the kernel compile config, this is necessary when the distro's kernel is already compiled
# with CONFIG_RANDOM_TRUST_CPU=y (e.g. RHEL > 8.3)
if grep -q CONFIG_RANDOM_TRUST_CPU /boot/config-`uname -r`; then
    sed -Ei 's/(.*)CONFIG_RANDOM_TRUST_CPU=.(.*)/\1CONFIG_RANDOM_TRUST_CPU=N\2/' /boot/config-`uname -r`
fi
