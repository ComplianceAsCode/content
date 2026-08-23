#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /var/cdrom iso9660 nodev 0 0" > /etc/fstab
