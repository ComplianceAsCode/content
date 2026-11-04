#!/bin/bash

GRUB_FILES=(/etc/default/grub /etc/grub2.cfg)
GRUB_FILES+=($(ls /etc/grub.d/* 2>/dev/null))
for file in "${GRUB_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        sed -i -r --follow-symlinks "s/selinux=0//gI" "$file"
        sed -i -r --follow-symlinks "s/enforcing=0//gI" "$file"
    fi
done
