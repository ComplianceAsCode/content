#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /media/cdrom iso9660 ro,noauto,nosuid,nodev,noexec 0 0" >> /etc/fstab
