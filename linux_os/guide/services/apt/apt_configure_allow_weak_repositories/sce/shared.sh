#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

explicit=false
for config_file in /etc/apt/apt.conf /etc/apt/apt.conf.d/*; do
    [[ -f "$config_file" ]] || continue
    [[ "$config_file" == /etc/apt/apt.conf || ${config_file##*/} =~ ^[A-Za-z0-9_-]+$ ]] || continue
    grep -Piq '^[\h]*(Acquire::)?AllowWeakRepositories\h+' "$config_file" && explicit=true
done

if [[ "$explicit" == true ]] && apt-config dump 2>/dev/null | grep -Piq '^Acquire::AllowWeakRepositories\s+"?(0|false|no|without|off)"?;$'; then
    exit "$XCCDF_RESULT_PASS"
fi

echo 'Acquire::AllowWeakRepositories is not explicitly configured with a disabled value.'
exit "$XCCDF_RESULT_FAIL"
