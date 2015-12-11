. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_password_pam_tally_deny

if [ $(grep auth.*required.*pam_tally2 /etc/pam.d/system-auth | grep -c "deny=") != 0 ]; then
	sed -i "/account.*required.*pam_tally/s/deny=[0-9]*/deny=${var_accounts_password_pam_tally_deny}/" /etc/pam.d/system-auth
elif [ $(grep -c "auth.*required.*pam_tally2" /etc/pam.d/system-auth) = 0 ]; then
	if [ $(grep -c "pam_tally.so" /etc/pam.d/system-auth) != 0 ]; then
		sed -i "s/pam_tally.so/pam_tally2.so/g" /etc/pam.d/system-auth
	elif [ $(grep -c "auth.*include.*system-auth-ac" /etc/pam.d/system-auth) != 0 ]; then
		sed -i 's/\(auth\s*include\s*system-auth-ac\)/auth        required     pam_tally2.so\n\1/' /etc/pam.d/system-auth
	elif [ $(grep -c "auth.*pam_unix.so" /etc/pam.d/system-auth) != 0 ]; then
		sed -i 's/\(auth.*pam_unix.so\)/auth        required     pam_tally2.so\n\1/' /etc/pam.d/system-auth
	elif [ $(grep -c "auth.*pam_deny.so" /etc/pam.d/system-auth) != 0 ]; then
		sed -i 's/\(auth.*pam_deny.so\)/auth        required     pam_tally2.so\n\1/' /etc/pam.d/system-auth
	else
		sed -i ':a;N;$!ba;s/\([\n]*[#]*[\s]*account\)/\nauth        required     pam_tally2.so\n\1/' /etc/pam.d/system-auth
	fi
	sed -i "/auth.*pam_tally/s/$/ deny=${var_accounts_password_pam_tally_deny}/" /etc/pam.d/system-auth
else
	sed -i "/auth.*pam_tally/s/$/ deny=${var_accounts_password_pam_tally_deny}/" /etc/pam.d/system-auth
fi
if [ ! -e /var/log/tallylog ]; then
	>/var/log/tallylog
fi
chmod 640 /var/log/tallylog
chown root:root /var/log/tallylog
