# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

 sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.d/*

if ! grep -qE '^\s*\$FileCreateMode\s+0640' /etc/rsyslog.conf; then
    if grep -qE '^\s*\$FileCreateMode' /etc/rsyslog.conf; then
        sed -i '/^\s*\$FileCreateMode/ s/^/#/' /etc/rsyslog.conf
    fi
    ## Assume there is no filter named as 00-, otherwise those filters might be included before this configuration and create file with different permissions
    echo '$FileCreateMode 0640' > /etc/rsyslog.d/00-rsyslog_filecreatemode.conf
fi

systemctl restart rsyslog.service
