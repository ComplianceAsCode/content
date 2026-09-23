#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

# Read the main file and drop-ins in systemd's precedence order.
journal_config_readable=true
journal_config=$(systemd-analyze cat-config systemd/journald.conf 2>/dev/null) || journal_config_readable=false
journal_setting() {
    awk -F= -v key="$1" -v fallback="$2" '
        BEGIN { value = fallback }
        /^[[:space:]]*[#;]/ { next }
        /^[[:space:]]*\[/ {
            section = $0
            gsub(/[[:space:]]/, "", section)
            next
        }
        section == "[Journal]" && NF == 2 {
            name = $1; setting = $2
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", setting)
            if (name == key) value = (setting == "" ? fallback : setting)
        }
        END { print value }
    ' <<< "$journal_config"
}

durable_path() {
    local filesystem options
    [[ -e "$1" && -w "$1" ]] || return 1
    read -r filesystem options < <(findmnt -n -o FSTYPE,OPTIONS -T "$1" 2>/dev/null)
    [[ -n "$filesystem" && "$filesystem" != tmpfs && "$filesystem" != ramfs &&
        ",$options," != *,ro,* ]]
}

storage=$(journal_setting Storage auto)
store_level=$(journal_setting MaxLevelStore debug)
# Ubuntu ships journald.conf with ForwardToSyslog=yes as the vendor default.
forward=$(journal_setting ForwardToSyslog yes)
syslog_level=$(journal_setting MaxLevelSyslog debug)

# Kernel command-line overrides take precedence over journald.conf.
read -r -a kernel_options < /proc/cmdline
for option in "${kernel_options[@]}"; do
    case "$option" in
        systemd.journald.forward_to_syslog=*) forward=${option#*=} ;;
        systemd.journald.max_level_store=*) store_level=${option#*=} ;;
        systemd.journald.max_level_syslog=*) syslog_level=${option#*=} ;;
    esac
done

if "$journal_config_readable" && systemctl is-active --quiet systemd-journald.service &&
    [[ "$storage" == persistent || "$storage" == auto ]] &&
    [[ "$store_level" =~ ^(notice|info|debug|5|6|7)$ ]] &&
    [[ -d /var/log/journal ]] && durable_path /var/log/journal; then
    exit "$XCCDF_RESULT_PASS"
fi

# Validate and expand loaded includes. An unreferenced .conf file is not evidence
# of logging. This branch covers the traditional file selectors used by Ubuntu
# and the CIS remediation, with journald forwarding to rsyslog's system socket.
if "$journal_config_readable" && systemctl is-active --quiet systemd-journald.service &&
    systemctl is-active --quiet rsyslog.service &&
    systemctl is-enabled --quiet rsyslog.service &&
    [[ "$forward" =~ ^(yes|true|on|1)$ ]] &&
    [[ "$syslog_level" =~ ^(notice|info|debug|5|6|7)$ ]] &&
    rsyslog_config=$(rsyslogd -N1 -o /dev/stdout 2>/dev/null); then
    input_pattern='^\h*(?:module\(\h*load="imuxsock"\h*\)|\$ModLoad\h+imuxsock)\h*(?:#.*)?$'
    if grep -Pq "$input_pattern" <<< "$rsyslog_config" &&
        ! grep -Piq '^\h*\$OmitLocalLogging\h+on\b' <<< "$rsyslog_config"; then
        while IFS= read -r logfile; do
            if [[ -f "$logfile" ]] && durable_path "$logfile"; then
                exit "$XCCDF_RESULT_PASS"
            fi
        done < <(awk '
            /^[[:space:]]*#/ || NF == 0 { next }
            # Do not infer routing through conditionals, rulesets or discards.
            /^[[:space:]]*:/ { exit }
            /^[[:space:]]*(if|ruleset|stop|&|~)([[:space:]({]|$)/ { exit }
            $2 == "~" || $2 == "stop" { exit }
            $1 ~ /^(authpriv|auth,authpriv|authpriv,auth)\.\*$/ &&
                $2 ~ /^-?\/var\/log\// {
                path = $2
                sub(/^-/, "", path)
                print path
            }
        ' <<< "$rsyslog_config")
    fi
fi

if ! dpkg-query --show --showformat='${db:Status-Status}' sudo-rs 2>/dev/null |
    grep -qx installed; then
    if grep -rPsiq \
        '^\h*Defaults\h+([^#]+,\h*)?logfile\h*=\h*("|'"'"')?\H+("|'"'"')?(,\h*\H+\h*)*\h*(#.*)?$' \
        /etc/sudoers /etc/sudoers.d 2>/dev/null; then
        exit "$XCCDF_RESULT_PASS"
    fi
fi

echo 'No durable sudo logging configuration with the required services was found.'
exit "$XCCDF_RESULT_FAIL"
