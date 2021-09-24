#!/bin/bash
#
# platform = Red Hat Enterprise Linux 7

{{% if init_system == "systemd" -%}}
service_file="/usr/lib/systemd/system/rescue.service"
sulogin='/bin/sh -c "/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin%" "$service_file"
{{%- else -%}}
grep -q ^SINGLE /etc/sysconfig/init && \
  sed -i "s/SINGLE.*/SINGLE=\/sbin\/sulogin/g" /etc/sysconfig/init
if ! [ $? -eq 0 ]; then
    echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init
fi
{{%- endif -%}}
