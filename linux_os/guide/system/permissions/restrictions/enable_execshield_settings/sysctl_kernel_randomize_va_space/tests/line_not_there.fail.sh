#!/bin/bash
#

sed -i "/^kernel.randomize_va_space.*/d" /etc/sysctl.conf
