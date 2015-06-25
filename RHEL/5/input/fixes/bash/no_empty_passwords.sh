sed -i 's/ nullok//g' /etc/pam.d/system-auth
if [ -e /etc/pam.d/system-auth-ac ]; then
	sed -i 's/ nullok//g' /etc/pam.d/system-auth-ac
fi
