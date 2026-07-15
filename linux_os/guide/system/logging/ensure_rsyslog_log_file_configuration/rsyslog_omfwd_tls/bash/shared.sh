# platform = multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

readarray -t files_containing_omfwd < <(grep -rlE '^\s*action\s*\(\s*type\s*=\s*"omfwd"' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null)
if [ ${#files_containing_omfwd[@]} -gt 0 ]; then
    for file in "${files_containing_omfwd[@]}"; do
        sed -i -E -e 'H;$!d;x;s/^\n//' \
            -e 's|(\s*action\s*\(\s*type\s*=\s*["]omfwd["].*?)tls\s*=\s*["][^"]*["](.*\))|\1tls="on"\2|gI' \
            "$file"
        if ! grep -qPzi '(?s)\s*action\s*\(\s*type\s*=\s*["]omfwd["].*?tls\s*=.*?\).*' "$file"; then
            sed -i -E -e 'H;$!d;x;s/^\n//' \
                -e 's|(\s*action\s*\(\s*type\s*=\s*["]omfwd["])|\1\ntls="on"|gI' \
                "$file"
        fi
    done
fi
