# platform = multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

USBGUARD_CONF=/etc/usbguard/rules.conf
if [ ! -f "$USBGUARD_CONF" ] || [ ! -s "$USBGUARD_CONF" ]; then
    usbguard generate-policy > $USBGUARD_CONF
    # make sure it has correct permissions
    chmod 600 $USBGUARD_CONF

    SYSTEMCTL_EXEC='/usr/bin/systemctl'
    "$SYSTEMCTL_EXEC" unmask 'usbguard.service'
    "$SYSTEMCTL_EXEC" restart 'usbguard.service'
    "$SYSTEMCTL_EXEC" enable 'usbguard.service'
fi
