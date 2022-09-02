#!/bin/bash
#
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

service_file="/usr/lib/systemd/system/rescue.service"
sulogin='/bin/sh -c "/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin%" "$service_file"
else
    echo "ExecStart=-$sulogin" >> "$service_file"
fi
