# platform = Red Hat Enterprise Linux 7
if rpm -qa | grep -q ypserv; then
	yum -y remove ypserv
fi
