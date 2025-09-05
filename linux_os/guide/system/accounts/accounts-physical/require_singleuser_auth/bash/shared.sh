# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

{{% if init_system == "systemd" -%}}

service_file="/usr/lib/systemd/system/rescue.service"

{{% if product in ["fedora", "rhel8", "ol8"] -%}}
sulogin="/usr/lib/systemd/systemd-sulogin-shell rescue"
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
