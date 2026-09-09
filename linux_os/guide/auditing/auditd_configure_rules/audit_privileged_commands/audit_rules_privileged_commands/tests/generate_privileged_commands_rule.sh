#!/bin/bash

AUID=$1
KEY=$2
RULEPATH=$3
MODE=${4:-}

mkdir -p "$(dirname "$RULEPATH")"
: > "$RULEPATH"

if [ "$MODE" = "parity" ]; then
    PRIV_CMD_DRACUT_EXCLUSION=(-not -path "/var/tmp/dracut*")
    PRIV_CMD_SYSROOT_EXCLUSION=(-not -path "/sysroot/*")
    PRIV_CMDS=""
    FILTER_NODEV=$(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,)
    PARTITIONS=$(findmnt -n -l -k -it "$FILTER_NODEV" | grep -Pv "noexec|nosuid|/proc($|/.*$)" | awk '{ print $1 }')
    for PARTITION in $PARTITIONS; do
        PRIV_CMDS+=$'\n'"$(find "${PARTITION}" -xdev -perm /6000 -type f \
          "${PRIV_CMD_DRACUT_EXCLUSION[@]}" 2>/dev/null)"
    done
    if [ -z "$(printf '%s' "$PRIV_CMDS" | tr -d '[:space:]')" ]; then
        PRIV_CMDS=$(find / -xdev -perm /6000 -type f \
          "${PRIV_CMD_SYSROOT_EXCLUSION[@]}" "${PRIV_CMD_DRACUT_EXCLUSION[@]}" 2>/dev/null)
    fi
else
    PRIV_CMDS=$(find / -not \( -fstype afs -o -fstype autofs -o -fstype ceph -o -fstype cifs -o -fstype smb3 -o -fstype smbfs -o -fstype sshfs -o -fstype ncpfs -o -fstype ncp -o -fstype nfs -o -fstype nfs4 -o -fstype gfs -o -fstype gfs2 -o -fstype glusterfs -o -fstype gpfs -o -fstype pvfs2 -o -fstype ocfs2 -o -fstype lustre -o -fstype davfs -o -fstype fuse.sshfs \) -type f \( -perm -4000 -o -perm -2000 \) 2> /dev/null)
fi

for file in $PRIV_CMDS; do
{{% if product in ["fedora", "rhel10"] %}}
    [ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")
    for ARCH in "${RULE_ARCHS[@]}" ; do
        echo "-a always,exit -F arch=$ARCH -F path=$file -F perm=x -F auid>=$AUID -F auid!=unset -k $KEY" >> $RULEPATH
    done
{{% else %}}
    echo "-a always,exit -F path=$file -F perm=x -F auid>=$AUID -F auid!=unset -k $KEY" >> $RULEPATH
{{% endif %}}
done
