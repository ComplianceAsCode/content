#!/bin/bash

# ensure that the option is not in kernel config file
if grep -q CONFIG_RANDOM_TRUST_CPU /boot/config-`uname -r`; then
    sed -Ei 's/(.*)CONFIG_RANDOM_TRUST_CPU=.(.*)/\1CONFIG_RANDOM_TRUST_CPU=N\2/' /boot/config-`uname -r`
fi

grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) random.trust_cpu=on"
