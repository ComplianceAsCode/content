#!/bin/bash
#
# platform = Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_cis

service_file="/usr/lib/systemd/system/emergency.service"

{{% if product in ["fedora", "rhel7", "ol7"] -%}}
sulogin="/usr/lib/systemd/systemd-sulogin-shell emergency"
{{%- else -%}}
sulogin='/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
{{%- endif %}}

if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin%" "$service_file"
else
    echo "ExecStart=-$sulogin" >> "$service_file"
fi
