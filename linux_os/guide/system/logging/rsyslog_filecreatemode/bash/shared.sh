# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

readarray -t targets < <(grep -H '^\s*$FileCreateMode' /etc/rsyslog.conf /etc/rsyslog.d/*)

# if $FileCreateMode set in multiple places
if [ ${#targets[@]} -gt 1 ]; then
    # delete all and create new entry with expected value
    sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/*
    echo '$FileCreateMode 0640' > /etc/rsyslog.d/99-rsyslog_filecreatemode.conf
# if $FileCreateMode set in only one place
elif [ "${#targets[@]}" -eq 1 ]; then
    filename=$(echo "${targets[0]}" | cut -d':' -f1)
    value=$(echo "${targets[0]}" | cut -d' ' -f2)
    #convert to decimal and bitwise or operation
    result=$((8#$value | 416))
    # if more permissive than expected, then set it to 0640
    if [ $result -ne 416 ]; then
        # if value is wrong remove it
        sed -i '/^\s*$FileCreateMode/d' $filename
        echo '$FileCreateMode 0640' > $filename
    fi
else
    echo '$FileCreateMode 0640' > /etc/rsyslog.d/99-rsyslog_filecreatemode.conf
fi

systemctl restart rsyslog.service
