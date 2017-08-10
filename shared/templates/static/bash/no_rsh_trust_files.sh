# platform = multi_platform_rhel
find /home -maxdepth 2 -type f -name .rhosts -exec rm -f '{}' \;
rm -f /etc/hosts.equiv
