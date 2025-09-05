# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

legacy_regex='^\s*\$(((Input(TCP|RELP)|UDP)ServerRun)|ModLoad\s+(imtcp|imudp|imrelp))'
rainer_regex='^\s*(module|input)\((load|type)="(imtcp|imudp)".*$'

readarray -t legacy_targets < <(grep -l -E -r "${legacy_regex[@]}" /etc/rsyslog.conf /etc/rsyslog.d/)
readarray -t rainer_targets < <(grep -l -E -r "${rainer_regex[@]}" /etc/rsyslog.conf /etc/rsyslog.d/)

config_changed=false
if [ ${#legacy_targets[@]} -gt 0 ]; then
    for target in "${legacy_targets[@]}"; do
        sed -E -i "/$legacy_regex/ s/^/# /" "$target"
    done
    config_changed=true
fi

if [ ${#rainer_targets[@]} -gt 0 ]; then
    for target in "${rainer_targets[@]}"; do
        sed -E -i "/$rainer_regex/ s/^/# /" "$target"
    done
    config_changed=true
fi

if $config_changed; then
    systemctl restart rsyslog.service
fi
