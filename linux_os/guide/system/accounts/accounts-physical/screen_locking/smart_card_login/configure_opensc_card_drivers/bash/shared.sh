# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

. /usr/share/scap-security-guide/remediation_functions
populate var_smartcard_drivers

grep -qs "card_drivers =" /etc/opensc*.conf && \
	sed -i "s/card_drivers =.*/card_drivers = $var_smartcard_drivers;/g" /etc/opensc*.conf
if ! [ $? -eq 0 ]; then
	sed -i "s/.*card_drivers =.*/        card_drivers = $var_smartcard_drivers;/g" /etc/opensc*.conf
fi
