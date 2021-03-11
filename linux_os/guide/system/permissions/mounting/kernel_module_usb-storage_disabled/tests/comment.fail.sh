#!/bin/bash

if [ -f /etc/modprobe.d/usb-storage.conf ]; then
    sed -i '/install usb-storage/d' /etc/modprobe.d/usb-storage.conf
fi
echo "# install usb-storage /bin/true" > /etc/modprobe.d/usb-storage.conf
