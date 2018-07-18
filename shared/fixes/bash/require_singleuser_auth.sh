# platform = multi_platform_rhel

{{% if init_system == "systemd" -%}}
grep -q "^ExecStart=\-.*/sbin/sulogin" /usr/lib/systemd/system/rescue.service
if ! [ $? -eq 0 ]; then
    sed -i "s/ExecStart=-.*-c \"/&\/sbin\/sulogin; /g" /usr/lib/systemd/system/rescue.service
fi
{{%- else -%}}
grep -q ^SINGLE /etc/sysconfig/init && \
  sed -i "s/SINGLE.*/SINGLE=\/sbin\/sulogin/g" /etc/sysconfig/init
if ! [ $? -eq 0 ]; then
    echo "SINGLE=/sbin/sulogin" >> /etc/sysconfig/init
fi
{{%- endif -%}}
