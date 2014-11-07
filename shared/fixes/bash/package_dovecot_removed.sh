if rpm -qa | grep -q dovecot; then
	yum -y remove dovecot
fi
