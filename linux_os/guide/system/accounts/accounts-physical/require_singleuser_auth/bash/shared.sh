# platform = multi_platform_all

{{% if init_system == "systemd" -%}}

service_file="/usr/lib/systemd/system/rescue.service"

{{% if product in ["fedora", "ol8", "ol9", "rhel8", "rhel9", "sle12", "sle15"] -%}}
sulogin="/usr/lib/systemd/systemd-sulogin-shell rescue"
{{%- elif product in ["rhel7"] -%}}
sulogin='/bin/sh -c "/usr/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
{{%- else -%}}
sulogin='/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
{{%- endif %}}

if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin%" "$service_file"
else
    echo "ExecStart=-$sulogin" >> "$service_file"
fi

{{%- else -%}}
grep -q ^SINGLE /etc/sysconfig/init && \
  sed -i "s/SINGLE.*/SINGLE=\/sbin\/sulogin/g" /etc/sysconfig/init
if ! [ $? -eq 0 ]; then
    echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init
fi
{{%- endif -%}}
