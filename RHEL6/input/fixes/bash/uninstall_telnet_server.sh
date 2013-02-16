if rpm -qa | grep -q telnet-server; then
	yum -y remove telnet-server
fi
