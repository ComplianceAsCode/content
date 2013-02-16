if ! rpm -qa | grep -q aide; then
	yum -y install aide
fi
