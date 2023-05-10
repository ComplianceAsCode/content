# platform = multi_platform_all

{{% if 'sle' in product %}}
service_dropin_cfg_dir="/etc/systemd/system/emergency.service.d"
service_dropin_file="${service_dropin_cfg_dir}/10-oscap.conf"
{{% else %}}
service_file="/usr/lib/systemd/system/emergency.service"
{{% endif %}}

{{% if product in ["fedora", "ol8", "ol9", "rhel8", "rhel9", "sle12", "sle15"] -%}}
sulogin="/usr/lib/systemd/systemd-sulogin-shell emergency"
{{%- else -%}}
sulogin='/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'
{{%- endif %}}

{{% if 'sle' in product %}}
mkdir -p "${service_dropin_cfg_dir}"
echo "[Service]" >> "${service_dropin_file}"
echo "ExecStart=-$sulogin" >> "${service_dropin_file}"
{{% else %}}
if grep "^ExecStart=.*" "$service_file" ; then
    sed -i "s%^ExecStart=.*%ExecStart=-$sulogin%" "$service_file"
else
    echo "ExecStart=-$sulogin" >> "$service_file"
fi
{{% endif %}}
