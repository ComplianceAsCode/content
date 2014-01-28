if rpm -qa | grep -q xinetd; then
	yum -y remove xinetd
fi
