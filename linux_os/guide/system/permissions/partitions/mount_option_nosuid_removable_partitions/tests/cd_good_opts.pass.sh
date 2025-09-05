#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /var/cdrom iso9660 nosuid 0 0" > /etc/fstab
