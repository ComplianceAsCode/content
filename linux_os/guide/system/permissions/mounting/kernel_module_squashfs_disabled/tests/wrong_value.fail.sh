#!/bin/bash

touch /etc/modprobe.d/squashfs.conf
sed -i '/install squashfs/d' /etc/modprobe.d/squashfs.conf
