if rpm -qa | grep -q httpd; then
	yum -y remove httpd
fi
