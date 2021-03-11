#!/bin/bash

touch /etc/modprobe.d/usb-storage.conf
sed -i '/install usb-storage/d' /etc/modprobe.d/usb-storage.conf
