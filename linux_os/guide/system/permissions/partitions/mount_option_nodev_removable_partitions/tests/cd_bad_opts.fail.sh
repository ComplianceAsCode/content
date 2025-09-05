#!/bin/bash

touch /dev/cdrom
echo "/dev/cdrom /var/cdrom iso9660 ro 0 0" > /etc/fstab
