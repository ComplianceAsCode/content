# platform = multi_platform_rhel, multi_platform_fedora

{{% if init_system == "systemd" -%}}

{{% if product == "fedora" -%}}
service_file="/usr/lib/systemd/system/rescue.service"
sulogin="/usr/lib/systemd/systemd-sulogin-shell"
if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin rescue%" "$service_file"
else
    echo "ExecStart=-$sulogin rescue" >> "$service_file"
fi
{{%- else -%}}
grep -q "^ExecStart=\-.*/sbin/sulogin" /usr/lib/systemd/system/rescue.service
if ! [ $? -eq 0 ]; then
    sed -i "s/ExecStart=-.*-c \"/&\/sbin\/sulogin; /g" /usr/lib/systemd/system/rescue.service
fi
{{%- endif -%}}

{{%- else -%}}
grep -q ^SINGLE /etc/sysconfig/init && \
  sed -i "s/SINGLE.*/SINGLE=\/sbin\/sulogin/g" /etc/sysconfig/init
if ! [ $? -eq 0 ]; then
    echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init
fi
{{%- endif -%}}
