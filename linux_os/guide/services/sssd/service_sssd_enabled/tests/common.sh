# sssd.service needs /etc/sssd/sssd.conf to start
if [ ! -f /etc/sssd/sssd.conf ]; then
	cat << EOF > /etc/sssd/sssd.conf
[sssd]
config_file_version = 2
services = nss, pam
domains = example.com

[domain/example.com]
{{%- if ('rhel' in product or 'ol' in families) and product not in ['ol8', 'ol9', 'rhel8', 'rhel9']%}}
id_provider = proxy
proxy_lib_name = files
local_auth_policy = only
{{%- else %}}
id_provider = files
access_provider = simple
simple_allow_users = user1, user2
{{%- endif %}}

[nss]
filter_groups = root
filter_users = root

[pam]
{{%- if ('rhel' in product or 'ol' in families) and product not in ['ol8', 'ol9', 'rhel8', 'rhel9']%}}
pam_cert_auth = True
{{%- endif %}}
EOF
	{{%- if ('rhel' in product or 'ol' in families) and product not in ['ol8', 'ol9', 'rhel8', 'rhel9']%}}
	dnf install sssd-proxy -y
	authselect select sssd with-smartcard
	chmod 0640 /etc/sssd/sssd.conf
	{{%- else %}}
	chmod 0600 /etc/sssd/sssd.conf
	{{%- endif %}}
fi
