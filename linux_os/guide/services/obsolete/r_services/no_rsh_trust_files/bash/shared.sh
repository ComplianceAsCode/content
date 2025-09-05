# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_sle

find /root -xdev -type f -name ".rhosts" -exec rm -f {} \;
find /home -maxdepth 2 -xdev -type f -name ".rhosts" -exec rm -f {} \;
rm -f /etc/hosts.equiv
