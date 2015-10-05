# platform = Red Hat Enterprise Linux 6
if rpm -qa | grep -q xinetd; then
	yum -y remove xinetd
fi
