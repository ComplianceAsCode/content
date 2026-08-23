#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol

service_file="/usr/lib/systemd/system/rescue.service"
sulogin="/usr/lib/systemd/systemd-sulogin-shell"
if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin rescue%" "$service_file"
else
    echo "ExecStart=-$sulogin rescue" >> "$service_file"
fi
