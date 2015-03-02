authconfig --updateall
if [ -e /etc/pam.d/system-auth-ac ]; then
	sed -i '/password.*include.*system-auth-ac/ipassword    required     pam_cracklib.so' /etc/pam.d/system-auth
else
	sed -i '/password.*unix.so/ipassword    required     pam_cracklib.so' /etc/pam.d/system-auth
fi
