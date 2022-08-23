#!/bin/bash

if [ -f "/etc/fstab" ]; then
    sed -i -E "/^\s*\S+\s+\S+\s+nfs/d" /etc/fstab
fi

echo "UUID=e06097bb-cfcd-437b-9e4d-a691f5662a7d /mount/point nfs rw,nosuid,nodev,noexec 0 0" >> /etc/fstab
echo "label=remote /store\040mount\011point nfs rw,nosuid,nodev,noexec 0 0" >> /etc/fstab
echo "host:/dir /host\040dir nfs rw,nosuid,nodev,noexec 0 0" >> /etc/fstab

sed -i -E "s/(^\s*\S+\s+\S+\s+nfs.*)(,{{{ MOUNTOPTION }}}|{{{ MOUNTOPTION }}},)(.*)/\1\3/g" /etc/fstab
