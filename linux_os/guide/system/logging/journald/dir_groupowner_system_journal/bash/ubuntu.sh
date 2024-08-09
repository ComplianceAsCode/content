# platform = multi_platform_ubuntu

TMPFILES_CONF="/usr/lib/tmpfiles.d/systemd.conf"

if ! grep -q 'Z /var/log/journal ~2750 root systemd-journal - -' "$TMPFILES_CONF"; then
    if grep -qP "^[zZ][+]*\s+\/var\/log\/journal" "$TMPFILES_CONF"; then
        sed -i --follow-symlinks "s/\(^[zZ][+]*\)\(\s\+\/var\/log\/journal.*\)/# \1\2/" "$TMPFILES_CONF"
    fi
    echo "Z /var/log/journal ~2750 root systemd-journal - -" >>"$TMPFILES_CONF"
fi

if ! grep -q 'Z /run/log/journal ~2750 root systemd-journal - -' "$TMPFILES_CONF"; then
    if grep -qP "^[zZ][+]*\s+\/run\/log\/journal" "$TMPFILES_CONF"; then
        sed -i --follow-symlinks "s/\(^[zZ][+]*\)\(\s\+\/run\/log\/journal.*\)/# \1\2/" "$TMPFILES_CONF"
    fi
    echo "Z /run/log/journal ~2750 root systemd-journal - -" >>"$TMPFILES_CONF"
fi

systemd-tmpfiles --create
