# platform = multi_platform_sle

[ -e /etc/security/opasswd ] || touch /etc/security/opasswd
chown root /etc/security/opasswd
chgrp root /etc/security/opasswd
chmod 0600 /etc/security/opasswd
