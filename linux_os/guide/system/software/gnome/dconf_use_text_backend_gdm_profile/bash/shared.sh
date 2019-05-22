# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol

mkdir -p /usr/share/dconf/profile/

if test -f /usr/share/dconf/profile/gdm
then
	sed -i '1s|^|service-db:keyfile/user\n|' /usr/share/dconf/profile/gdm
else
	echo 'service-db:keyfile/user' > /usr/share/dconf/profile/gdm
fi
