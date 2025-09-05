#!/bin/bash
# packages = gdm

sed -i "/^TimedLoginEnable=.*/d" /etc/gdm/custom.conf
