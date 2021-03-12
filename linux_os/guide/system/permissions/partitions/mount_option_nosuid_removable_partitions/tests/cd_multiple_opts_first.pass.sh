#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /media/cdrom iso9660 nosuid,ro,noauto,noexec,nodev 0 0" >> /etc/fstab
