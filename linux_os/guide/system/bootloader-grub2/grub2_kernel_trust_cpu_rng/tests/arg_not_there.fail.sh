#!/bin/bash
# Based on shared/templates/grub2_bootloader_argument/tests/arg_not_there.fail.sh
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8

# Removes audit argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*random\.trust_cpu=.*'  "$file" ; then
	sed -i 's/\(^.*\)random.trust_cpu=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi

# Fake the kernel compile config, this is necessary when the distro's kernel is already compiled
# with CONFIG_RANDOM_TRUST_CPU=y (e.g. RHEL > 8.3)
if grep -q CONFIG_RANDOM_TRUST_CPU /boot/config-`uname -r`; then
    sed -Ei 's/(.*)CONFIG_RANDOM_TRUST_CPU=.(.*)/\1CONFIG_RANDOM_TRUST_CPU=N\2/' /boot/config-`uname -r`
fi
