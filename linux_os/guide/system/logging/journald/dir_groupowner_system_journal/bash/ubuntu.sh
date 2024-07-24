# platform = multi_platform_ubuntu

TMPFILES_CONF="/usr/lib/tmpfiles.d/systemd.conf"

if grep -qP "^[zZ][+]*\s+\/var\/log\/journal\s+" "$TMPFILES_CONF"; then
    sed -i --follow-symlinks -E '/[zZ][+]*\s+\/var\/log\/journal\s*/d' "$TMPFILES_CONF"
fi
echo "Z /var/log/journal ~2750 root systemd-journal - -" >> "$TMPFILES_CONF"

if grep -qP "^[zZ][+]*\s+\/run\/log\/journal\s+" "$TMPFILES_CONF"; then
    sed -i --follow-symlinks -E '/[zZ][+]*\s+\/run\/log\/journal\s*/d' "$TMPFILES_CONF"
fi
echo "Z /run/log/journal ~2750 root systemd-journal - -" >> "$TMPFILES_CONF"

systemd-tmpfiles --create
