#!/bin/bash

if ! [ -f "/etc/grub2.cfg" ]; then
    touch /etc/grub2.cfg
fi

rm -f /etc/default/grub
GRUB_FILES=(/etc/grub2.cfg )
GRUB_FILES+=($(ls /etc/grub.d/* 2>/dev/null))
for file in "${GRUB_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        sed -i --follow-symlinks "s/selinux=0//gI" "$file"
        sed -i --follow-symlinks "s/enforcing=0//gI" "$file"
    fi
done
