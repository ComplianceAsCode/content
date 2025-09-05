#!/bin/bash

if grep -q CONFIG_RANDOM_TRUST_CPU /boot/config-`uname -r`; then
    sed -Ei 's/(.*)CONFIG_RANDOM_TRUST_CPU=.(.*)/\1CONFIG_RANDOM_TRUST_CPU=N\2/' /boot/config-`uname -r`
fi

file="/boot/grub2/grubenv"
if grep -q '^.*random.trust_cpu=.*'  "$file" ; then
	sed -i 's/\(^.*\)random.trust_cpu=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
fi
