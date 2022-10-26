# platform = multi_platform_sle

# Create /etc/security/opasswd if needed
# Owner group mode root.root 0600
if [ ! -f /etc/security/opasswd ]; then
        # Create the file
        touch /etc/security/opasswd
fi

chown root:root /etc/security/opasswd
chmod 0600 /etc/security/opasswd

