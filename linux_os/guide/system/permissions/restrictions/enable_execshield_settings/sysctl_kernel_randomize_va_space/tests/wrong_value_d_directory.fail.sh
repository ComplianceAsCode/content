#!/bin/bash

. $SHARED/sysctl.sh

setting_name="kernel.randomize_va_space"
setting_value="2"
# sysctl -w "$setting_name=$setting_value"
if grep -q "^$setting_name" /etc/sysctl.conf; then
    sed -i "s/^$setting_name.*/$setting_name = $setting_value/" /etc/sysctl.conf
else
    echo "$setting_name = $setting_value" >> /etc/sysctl.conf
fi

setting_name="kernel.randomize_va_space"
setting_value="0"
# sysctl -w "$setting_name=$setting_value"
if grep -q "^$setting_name" /etc/sysctl.d/98-sysctl.conf; then
    sed -i "s/^$setting_name.*/$setting_name = $setting_value/" /etc/sysctl.d/98-sysctl.conf
else
    echo "$setting_name = $setting_value" >> /etc/sysctl.d/98-sysctl.conf
fi

sysctl --system
