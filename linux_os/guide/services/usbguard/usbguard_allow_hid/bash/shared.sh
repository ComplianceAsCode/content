# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

# path of file with Usbguard rules
rulesfile="/etc/usbguard/rules.conf"

echo "allow with-interface match-all { 03:*:* }" >> $rulesfile
