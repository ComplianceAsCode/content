# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

if ! grep -Eq '^[ \t]*allow[ \t]+with-interface[ \t]+equals[ \t]+\{[ \t]+09:00:\*[ \t]+\}[ \t]*$' /etc/usbguard/rules.conf ; then
	echo "allow with-interface equals { 09:00:* }" >> /etc/usbguard/rules.conf
fi
