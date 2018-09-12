function set-up-pamd {
	mkdir -p /etc/pam.d
	cp -rf auth-config /etc/pam.d/system-auth
	cp -rf auth-config /etc/pam.d/password-auth
}
