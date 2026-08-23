#!/bin/bash
# Based on shared/templates/grub2_bootloader_argument/tests/wrong_value_entries.fail.sh
# platform = Red Hat Enterprise Linux 9

# Breaks argument in kernel command line in /boot/loader/entries/*.conf

for file in /boot/loader/entries/*.conf ; do
  if grep -q '^.*CONFIG_RANDOM_TRUST_CPU=.*'  "$file" ; then
      # modify the GRUB command-line if an already exists
	    sed -i 's/\(^.*\)CONFIG_RANDOM_TRUST_CPU=[^[:space:]]*\(.*\)/\1 CONFIG_RANDOM_TRUST_CPU=wrong \2/'  "$file"
    else
	    # no argument is present, append it
	    sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 CONFIG_RANDOM_TRUST_CPU=wrong/'  "$file"
  fi
done

# Fake the kernel compile config, this is necessary when the distro's kernel is already compiled
# with CONFIG_RANDOM_TRUST_CPU=y (e.g. RHEL > 8.3)
if grep -q CONFIG_RANDOM_TRUST_CPU /boot/config-`uname -r`; then
    sed -Ei 's/(.*)CONFIG_RANDOM_TRUST_CPU=.(.*)/\1CONFIG_RANDOM_TRUST_CPU=N\2/' /boot/config-`uname -r`
fi
