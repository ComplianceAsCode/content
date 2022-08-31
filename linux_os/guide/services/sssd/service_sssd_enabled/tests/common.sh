# sssd.service needs /etc/sssd/sssd.conf to start
if [ ! -f /etc/sssd/sssd.conf ]; then
	cat << EOF > /etc/sssd/sssd.conf
[sssd]
config_file_version = 2
services = nss, pam
domains = example.com

[domain/example.com]
id_provider = files
access_provider = simple
simple_allow_users = user1, user2

[nss]
filter_groups = root
filter_users = root

[pam]
EOF
	chmod 0600 /etc/sssd/sssd.conf
fi
