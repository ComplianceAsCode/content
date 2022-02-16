# platform = multi_platform_all

[ -f  /etc/security/opasswd ] || touch /etc/security/opasswd
chown root:root /etc/security/opasswd
chmod 0600 /etc/security/opasswd
