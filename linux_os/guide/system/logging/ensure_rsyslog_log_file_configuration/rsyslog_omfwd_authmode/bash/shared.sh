# platform = multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("rsyslog_remote_loghost_address") }}}

readarray -t files_containing_omfwd < <(grep -rlE '^\s*action\s*\(\s*type\s*=\s*"omfwd"' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null)
if [ ${#files_containing_omfwd[@]} -gt 0 ]; then
    for file in "${files_containing_omfwd[@]}"; do
        sed -i -E -e 'H;$!d;x;s/^\n//' \
            -e 's|(\s*action\s*\(\s*type\s*=\s*["]omfwd["].*?)(streamdriver\.authmode\|tls\.authmode\|streamdriverauthmode)\s*=\s*["][^"]*["](.*\))|\1streamdriver.authmode="x509/name"\3|gI' \
            "$file"
        if ! grep -qPzi '(?s)\s*action\s*\(\s*type\s*=\s*["]omfwd["].*?(streamdriver\.authmode|tls\.authmode|streamdriverauthmode)\s*=.*?\).*' "$file"; then
            sed -i -E -e 'H;$!d;x;s/^\n//' \
                -e 's|(\s*action\s*\(\s*type\s*=\s*["]omfwd["])|\1\nstreamdriver.authmode="x509/name"|gI' \
                "$file"
        fi
        sed -i -E -e 'H;$!d;x;s/^\n//' \
            -e "s|(\s*action\s*\(\s*type\s*=\s*[\"]omfwd[\"].*?)(streamdriver\.permittedpeer\|tls\.permittedpeer\|streamdriverpermittedpeer)\s*=\s*[\"][^\"]*[\"](.*\))|\1streamdriver.permittedpeer=\"$rsyslog_remote_loghost_address\"\3|gI" \
            "$file"
        if ! grep -qPzi '(?s)\s*action\s*\(\s*type\s*=\s*["]omfwd["].*?(streamdriver\.permittedpeer|tls\.permittedpeer|streamdriverpermittedpeer)\s*=.*?\).*' "$file"; then
            sed -i -E -e 'H;$!d;x;s/^\n//' \
                -e "s|(\s*action\s*\(\s*type\s*=\s*[\"]omfwd[\"])|\1\nstreamdriver.permittedpeer=\"$rsyslog_remote_loghost_address\"|gI" \
                "$file"
        fi
    done
fi
