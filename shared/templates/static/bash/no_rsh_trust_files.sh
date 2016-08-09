# platform = multi_platform_rhel
find -type f -name .rhosts -exec rm -f '{}' \;
rm /etc/hosts.equiv
