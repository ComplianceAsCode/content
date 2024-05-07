# platform = multi_platform_ubuntu

TMPFILES_CONF="/etc/tmpfiles.d/systemd.conf"

if grep -qP "^.[+]*\s+\/var\/log\/journal\s+" "$TMPFILES_CONF"; then
    sed -i --follow-symlinks "s/\(^.[+]*\)\(\s\+\/var\/log\/journal\s\+[^ $]\+\s\+[^ $]\+\s\+\)\([^ $]\+\)/Z\2systemd-journal/" "$TMPFILES_CONF"
else
    echo "Z /var/log/journal ~2750 root systemd-journal - -" >> "$TMPFILES_CONF"
fi

if grep -qP "^.[+]*\s+\/run\/log\/journal\s+" "$TMPFILES_CONF"; then
    sed -i --follow-symlinks "s/\(^.[+]*\)\(\s\+\/run\/log\/journal\s\+[^ $]\+\s\+[^ $]\+\s\+\)\([^ $]\+\)/Z\2systemd-journal/" "$TMPFILES_CONF"
else
    echo "Z /run/log/journal ~2750 root systemd-journal - -" >> "$TMPFILES_CONF"
fi

systemd-tmpfiles --create
