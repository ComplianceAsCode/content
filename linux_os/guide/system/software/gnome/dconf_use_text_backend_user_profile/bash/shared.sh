# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol

mkdir -p /etc/dconf/profile

if test -f /etc/dconf/profile/user
then
	sed -i '1s|^|service-db:keyfile/user\n|' /etc/dconf/profile/user
else
	echo 'service-db:keyfile/user' > /etc/dconf/profile/user
fi
