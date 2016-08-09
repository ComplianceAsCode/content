if [ -e /tmp/GRUB.TMP ]; then
	/sbin/grub-md5-crypt < /tmp/GRUB.TMP &> /tmp/GRUB.TMP.out
	md5crypt=`tail -n1 /tmp/GRUB.TMP.out`
	if [ -f /boot/grub/grub.conf ] && [ ! -h /boot/grub/grub.conf ]; then
		if [ "$(grep -c '^password' /boot/grub/grub.conf)" = "0" ]; then
			sed -i "/timeout/apassword --md5 ${md5crypt}" /boot/grub/grub.conf
		else
			sed -i "s/^password .*/password --md5 ${md5crypt}/" /boot/grub/grub.conf
		fi
	fi
	if [ -f /etc/grub.conf ] && [ ! -h /etc/grub.conf ]; then
		if [ "$(grep -c '^password' /etc/grub.conf)" = "0" ]; then
			sed -i "/timeout/apassword --md5 ${md5crypt}" /etc/grub.conf
		else
			sed -i "s/^password .*/password --md5 ${md5crypt}/" /etc/grub.conf
		fi
	fi
	rm -f /tmp/GRUB.TMP /tmp/GRUB.TMP.out
fi
