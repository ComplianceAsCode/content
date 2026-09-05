#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

explicit=false
for config_file in /etc/apt/apt.conf /etc/apt/apt.conf.d/*; do
    [[ -f "$config_file" ]] || continue
    [[ "$config_file" == /etc/apt/apt.conf || ${config_file##*/} =~ ^[A-Za-z0-9_-]+$ ]] || continue
    grep -Piq '^[\h]*(Acquire::)?Check-Date\h+' "$config_file" && explicit=true
done

if [[ "$explicit" == true ]] && apt-config dump 2>/dev/null | grep -Piq '^Acquire::Check-Date\s+"?(1|true|yes|with|on)"?;$'; then
    exit "$XCCDF_RESULT_PASS"
fi

echo 'Acquire::Check-Date is not explicitly configured with an enabled value.'
exit "$XCCDF_RESULT_FAIL"
