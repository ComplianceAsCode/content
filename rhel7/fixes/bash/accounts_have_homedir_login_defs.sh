# platform = Red Hat Enterprise Linux 7

if ! grep -q ^CREATE_HOME /etc/login.defs; then
	echo "CREATE_HOME     yes" >> /etc/login.defs
else
	sed -i "s/^\(CREATE_HOME\).*/\1 yes/g" /etc/login.defs
fi
