# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

 {{{ bash_instantiate_variables("rsyslog_remote_loghost_address") }}}
params_to_add_if_missing=("protocol" "target" "port" "StreamDriver" "StreamDriverMode" "StreamDriverAuthMode" "streamdriver.CheckExtendedKeyPurpose")
values_to_add_if_missing=("tcp" "$rsyslog_remote_loghost_address" "6514" "gtls" "1" "x509/name" "on")
params_to_replace_if_wrong_value=("protocol" "StreamDriver" "StreamDriverMode" "StreamDriverAuthMode" "streamdriver.CheckExtendedKeyPurpose")
values_to_replace_if_wrong_value=("tcp" "gtls" "1" "x509/name" "on")

files_containing_omfwd=("$(grep -ilE '^[^#]*\s*action\s*\(\s*type\s*=\s*"omfwd".*' /etc/rsyslog.conf /etc/rsyslog.d/*.conf)")
if [ -n "${files_containing_omfwd[*]}" ]; then
    for file in "${files_containing_omfwd[@]}"; do
        for ((i=0; i<${#params_to_replace_if_wrong_value[@]}; i++)); do
            sed -i -E -e 'H;$!d;x;s/^\n//' -e "s|(\s*action\s*\(\s*type\s*=\s*[\"]omfwd[\"].*?)${params_to_replace_if_wrong_value[$i]}\s*=\s*[\"]\S*[\"](.*\))|\1${params_to_replace_if_wrong_value[$i]}=\"${values_to_replace_if_wrong_value[$i]}\"\2|gI" "$file"
        done
        for ((i=0; i<${#params_to_add_if_missing[@]}; i++)); do
            if ! grep -qPzi "(?s)\s*action\s*\(\s*type\s*=\s*[\"]omfwd[\"].*?${params_to_add_if_missing[$i]}.*?\).*" "$file"; then
                sed -i -E -e 'H;$!d;x;s/^\n//' -e "s|(\s*action\s*\(\s*type\s*=\s*[\"]omfwd[\"])|\1\n${params_to_add_if_missing[$i]}=\"${values_to_add_if_missing[$i]}\"|gI" "$file"
            fi
        done
    done
else
    echo "action(type=\"omfwd\" protocol=\"tcp\" Target=\"$rsyslog_remote_loghost_address\" port=\"6514\" StreamDriver=\"gtls\" StreamDriverMode=\"1\" StreamDriverAuthMode=\"x509/name\" streamdriver.CheckExtendedKeyPurpose=\"on\")"  >> /etc/rsyslog.conf
fi
