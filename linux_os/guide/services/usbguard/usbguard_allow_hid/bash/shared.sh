# platform = multi_platform_all

# path of file with Usbguard rules
rulesfile="/etc/usbguard/rules.conf"

echo "allow with-interface match-all { 03:*:* }" >> $rulesfile
