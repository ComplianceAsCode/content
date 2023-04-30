#!/bin/bash

# Paths to configuration files and directories for modprobe
rm -f -- \
    /etc/modprobe.conf \
    /etc/modprobe.d/*.conf /run/modprobe.d/*.conf /usr/lib/modprobe.d/*.conf \
    /etc/modules-load.d/*.conf /run/modules-load.d/*.conf /usr/lib/modules-load.d/*.conf \
    /etc/dracut.conf /etc/dracut.conf.d/*.conf
