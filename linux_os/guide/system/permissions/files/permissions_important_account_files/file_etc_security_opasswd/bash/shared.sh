# platform = multi_platform_sle,multi_platform_slmicro

# Create /etc/security/opasswd if needed
# Owner group mode root.root 0600
[ -f  /etc/security/opasswd ] || touch /etc/security/opasswd
chown root:root /etc/security/opasswd
chmod 0600 /etc/security/opasswd
