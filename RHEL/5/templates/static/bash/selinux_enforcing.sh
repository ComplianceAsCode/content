. /usr/share/scap-security-guide/remediation_functions
populate var_selinux_policy_name

if [ "`grep -c ^SELINUX= /etc/sysconfig/selinux`" = "0" ]; then
	echo SELINUX=enforcing >> /etc/sysconfig/selinux
else
	sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/sysconfig/selinux
fi

if [ "`grep -c ^SELINUX= /etc/selinux/config`" = "0" ]; then
	echo SELINUX=enforcing >> /etc/selinux/config
else
	sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
fi

if [ "`grep -c ^SELINUXTYPE= /etc/sysconfig/selinux`" = "0" ]; then
	echo SELINUXTYPE=${var_selinux_policy_name} >> /etc/sysconfig/selinux
else
	sed -i "s/^SELINUXTYPE=.*/SELINUXTYPE=${var_selinux_policy_name}/" /etc/sysconfig/selinux
fi

if [ "`grep -c ^SELINUXTYPE= /etc/selinux/config`" = "0" ]; then
	echo SELINUXTYPE=${var_selinux_policy_name} >> /etc/selinux/config
else
	sed -i "s/^SELINUXTYPE=.*/SELINUXTYPE=${var_selinux_policy_name}/" /etc/selinux/config
fi
