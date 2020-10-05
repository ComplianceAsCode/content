#!/bin/bash
# packages = gdm

sed -i "/^AutomaticLoginEnable=.*/d" /etc/gdm/custom.conf
