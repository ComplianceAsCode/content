#!/bin/bash
# Tab character breaks ansible's mount module, in current status ansible will leave this fstab line as is
# remediation = bash

if [ -f "/etc/fstab" ]; then
    sed -i -E "/^\s*\S+\s+\S+\s+nfs/d" /etc/fstab
fi

echo "label=remote /store\040mount\011point nfs rw,nosuid,nodev,noexec 0 0" >> /etc/fstab

sed -i -E "s/(^\s*\S+\s+\S+\s+nfs.*)(,{{{ MOUNTOPTION }}}|{{{ MOUNTOPTION }}},)(.*)/\1\3/g" /etc/fstab
