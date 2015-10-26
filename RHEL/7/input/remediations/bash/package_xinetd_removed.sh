# platform = Red Hat Enterprise Linux 7
if rpm -qa | grep -q xinetd; then
	yum -y remove xinetd
fi
