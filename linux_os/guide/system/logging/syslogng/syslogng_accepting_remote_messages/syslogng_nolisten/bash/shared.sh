# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

network_regex='^\s*(tcp|udp|network)\('

readarray -t targets < <(grep -l -E -r "${network_regex}" /etc/syslog-ng/ 2>/dev/null)

config_changed=false
if [ ${#targets[@]} -gt 0 ]; then
    for target in "${targets[@]}"; do
        sed -E -i "/${network_regex}/ s/^/# /" "$target"
    done
    config_changed=true
fi

if $config_changed; then
    systemctl restart syslog-ng.service
fi
