#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

service_file="/usr/lib/systemd/system/emergency.service"
sulogin="/usr/lib/systemd/systemd-sulogin-shell"
if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin emergency%" "$service_file"
else
    echo "ExecStart=-$sulogin emergency" >> "$service_file"
fi
