# platform = Red Hat Enterprise Linux 7,multi_platform_fedora
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

. /usr/share/scap-security-guide/remediation_functions
populate var_smartcard_drivers

grep -qs "force_card_driver =" /etc/opensc*.conf && \
	sed -i "s/force_card_driver =.*/force_card_driver = $var_smartcard_drivers;/g" /etc/opensc*.conf
if ! [ $? -eq 0 ]; then
	sed -i "s/.*force_card_driver =.*/        force_card_driver = $var_smartcard_drivers;/g" /etc/opensc*.conf
fi
