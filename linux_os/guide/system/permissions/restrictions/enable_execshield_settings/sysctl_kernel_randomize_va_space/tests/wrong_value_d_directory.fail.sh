#!/bin/bash

. $SHARED/sysctl.sh

setting_name="kernel.randomize_va_space"
setting_value="2"
# sysctl -w "$setting_name=$setting_value"
if grep -q "^$setting_name" /usr/lib/sysctl.d/50-sysctl.conf; then
    sed -i "s/^$setting_name.*/$setting_name = $setting_value/" /usr/lib/sysctl.d/50-sysctl.conf
else
    echo "$setting_name = $setting_value" >> /usr/lib/sysctl.d/50-sysctl.conf
fi

setting_name="kernel.randomize_va_space"
setting_value="0"
# sysctl -w "$setting_name=$setting_value"
if grep -q "^$setting_name" /etc/sysctl.d/99-sysctl.conf; then
    sed -i "s/^$setting_name.*/$setting_name = $setting_value/" /etc/sysctl.d/99-sysctl.conf
else
    echo "$setting_name = $setting_value" >> /etc/sysctl.d/99-sysctl.conf
fi

sysctl --system
