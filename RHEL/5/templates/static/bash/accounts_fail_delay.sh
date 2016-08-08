if [ $(grep -c ^FAIL_DELAY /etc/login.defs) != 0 ]; then
	sed -i 's/^FAIL_DELAY.*[0-9]*/FAIL_DELAY 4/' /etc/login.defs
else
	echo "FAIL_DELAY 4" | tee -a /etc/login.defs &>/dev/null
fi

if [ $(grep -c pam_faildelay.so /etc/pam.d/system-auth) != 0 ]; then
	if [ $(grep -c pam_faildelay.so.*delay\= /etc/pam.d/system-auth) != 0 ]; then
		sed -i '/pam_faildelay.so/s/\(delay=\)[0-9]*/\14000000/' /etc/pam.d/system-auth
	else
		sed -i '/pam_faildelay.so/s/$/ delay=4000000/' /etc/pam.d/system-auth
	fi
else
	sed -i '/auth.*include.*system-auth-ac/iauth        optional     pam_faildelay.so delay=4000000' /etc/pam.d/system-auth
fi
