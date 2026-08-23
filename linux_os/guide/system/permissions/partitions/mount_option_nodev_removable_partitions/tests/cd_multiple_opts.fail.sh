#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /media/cdrom iso9660 ro,noauto,noexec,nosuid,defaults 0 0" >> /etc/fstab
