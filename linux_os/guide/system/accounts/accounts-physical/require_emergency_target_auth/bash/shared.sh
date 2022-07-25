# platform = multi_platform_all

service_file="/usr/lib/systemd/system/emergency.service"

{{% if product in ["fedora", "ol8", "ol9", "rhel8", "rhel9", "sle12", "sle15"] -%}}
sulogin="/usr/lib/systemd/systemd-sulogin-shell emergency"
{{%- else -%}}
sulogin='/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
{{%- endif %}}

if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin%" "$service_file"
else
    echo "ExecStart=-$sulogin" >> "$service_file"
fi
