# platform = Red Hat Enterprise Linux 6
if rpm -qa | grep -q samba; then
	yum -y remove samba
fi
