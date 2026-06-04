# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

find /etc/rsyslog.d/ -name '*.conf' -exec sed -i '/^\s*\$FileCreateMode/d' {} +

changes_made=false
if ! grep -qE '^\s*\$FileCreateMode\s+0640' /etc/rsyslog.conf; then
    if grep -qE '^\s*\$FileCreateMode' /etc/rsyslog.conf; then
        sed -i '/^\s*\$FileCreateMode/ s/^/#/' /etc/rsyslog.conf
    fi
    ## Assume there is no filter named as 00-, otherwise those filters might be included before this configuration and create file with different permissions
    echo '$FileCreateMode 0640' > /etc/rsyslog.d/00-rsyslog_filecreatemode.conf
    changes_made=true
fi

if [[ "$changes_made" == "true" ]] && [[ $(systemctl is-system-running) != "offline" ]]; then
    systemctl restart rsyslog.service
fi
