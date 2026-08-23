#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /media/cdrom iso9660 ro,noauto,noexec,nodev,defaults 0 0" >> /etc/fstab
