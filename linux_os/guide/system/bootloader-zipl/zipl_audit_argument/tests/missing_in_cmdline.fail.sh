#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

# Make sure boot loader entries contain audit=1
for file in /boot/loader/entries/*.conf
do
    if ! grep -q '^options.*audit=1.*$' "$file" ; then
        sed -i '/^options / s/$/ audit=1/' "$file"
    fi
done

# Make sure /etc/kernel/cmdline doesn't contain audit=1
sed -Ei 's/(^.*)audit=1(.*?)$/\1\2/' /etc/kernel/cmdline || true
