#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /media/cdrom iso9660 nodev,ro,noauto,nosuid,noexec 0 0" >> /etc/fstab
