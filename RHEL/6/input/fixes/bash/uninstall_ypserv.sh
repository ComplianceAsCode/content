if rpm -qa | grep -q ypserv; then
	yum -y remove ypserv
fi
