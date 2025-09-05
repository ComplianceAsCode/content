#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /media/cdrom iso9660 noexec,ro,noauto,nosuid,nodev 0 0" >> /etc/fstab
