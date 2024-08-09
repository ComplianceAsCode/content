#!/bin/bash

cat >/etc/fstab <<ENDOF


#
# /etc/fstab
# Created by anaconda on Wed Aug  7 08:51:34 2025
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/system-root /                       xfs     defaults        0 0
UUID=07fc30bd-875f-48bd-8863-e62e49e42716 /boot                   xfs     defaults,nosuid        0 0
/dev/mapper/system-home /home                   xfs     defaults,noexec,nosuid        0 0
/dev/mapper/system-tmp  /tmp                    xfs     defaults,noexec,nosuid        0 0
/dev/mapper/system-var  /var                    xfs     defaults        0 0
/dev/mapper/system-varlog /var/log                xfs     defaults,noexec,nosuid        0 0
/dev/mapper/system-varlogaudit /var/log/audit          xfs     defaults,noexec,nosuid        0 0
/dev/mapper/system-vartmp /var/tmp                xfs     defaults,noexec,nosuid        0 0
/dev/mapper/system-swap none                    swap    defaults        0 0
tmpfs /dev/shm tmpfs defaults,relatime,inode64,noexec,nosuid 0 0
ENDOF
