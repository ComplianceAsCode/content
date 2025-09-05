#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8, Red Hat Enterprise Linux 9

# Make sure boot loader entries contain init_on_alloc=1
for file in /boot/loader/entries/*.conf
do
    if ! grep -q '^options.*init_on_alloc=1.*$' "$file" ; then
        sed -i '/^options / s/$/ init_on_alloc=1/' "$file"
    fi
done

# Make sure /etc/kernel/cmdline contains init_on_alloc=1
if ! grep -qs '^(.*\s)?init_on_alloc=1(\s.*)?$' /etc/kernel/cmdline ; then
    echo "init_on_alloc=1" >> /etc/kernel/cmdline
fi
