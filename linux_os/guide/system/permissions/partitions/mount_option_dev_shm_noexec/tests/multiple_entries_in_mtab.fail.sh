#!/bin/bash

cat /etc/mtab > /etc/mtab.old
# destroy symlink
rm -f /etc/mtab
cp /etc/mtab.old /etc/mtab
echo "tmpfs /dev/shm tmpfs rw,seclabel,relatime 0 0" >> /etc/mtab
echo "tmpfs /dev/shm tmpfs rw,seclabel,relatime 0 0" >> /etc/mtab
