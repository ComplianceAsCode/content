# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

if ! grep -Eq '^[ \t]*allow[ \t]+with-interface[ \t]+equals[ \t]+\{[ \t]+03:\*:\*[ \t]+\}[ \t]*$' /etc/usbguard/rules.conf ; then
	echo "allow with-interface equals { 03:*:* }" >> /etc/usbguard/rules.conf
fi
if ! grep -Eq '^[ \t]*allow[ \t]+with-interface[ \t]+equals[ \t]+\{[ \t]+03:\*:\*[ \t]+03:\*:\*[ \t]+\}[ \t]*$' /etc/usbguard/rules.conf ; then
	echo "allow with-interface equals { 03:*:* 03:*:* }" >> /etc/usbguard/rules.conf
fi
