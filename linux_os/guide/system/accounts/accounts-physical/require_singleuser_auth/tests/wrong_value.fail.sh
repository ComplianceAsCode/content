#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora

service_file="/usr/lib/systemd/system/rescue.service"
sulogin="/bin/bash"
if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin rescue%" "$service_file"
else
    echo "ExecStart=-$sulogin rescue" >> "$service_file"
fi
