# platform = multi_platform_rhel
if ! grep -q "/usr/sbin/aide --check"; then
    echo "05 4 * * * root /usr/sbin/aide --check" >> /etc/crontab
fi
