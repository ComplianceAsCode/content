# platform = multi_platform_ol,multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low


if rpm --quiet -q usbguard
then
    USBGUARD_CONF=/etc/usbguard/rules.conf
    if [ ! -f "$USBGUARD_CONF" ] || [ ! -s "$USBGUARD_CONF" ]; then
        usbguard generate-policy > $USBGUARD_CONF
        if [ ! -s "$USBGUARD_CONF" ]; then
            # make sure OVAL check doesn't fail on systems where
            # generate-policy doesn't find any USB devices (for
            # example a system might not have a USB bus)
            echo "# No USB devices found" > $USBGUARD_CONF
        fi
        # make sure it has correct permissions
        chmod 600 $USBGUARD_CONF

        SYSTEMCTL_EXEC='/usr/bin/systemctl'
        "$SYSTEMCTL_EXEC" unmask 'usbguard.service'
        "$SYSTEMCTL_EXEC" restart 'usbguard.service'
        "$SYSTEMCTL_EXEC" enable 'usbguard.service'
    fi
else
    echo "USBGuard is not installed. No remediation was applied!"
fi
