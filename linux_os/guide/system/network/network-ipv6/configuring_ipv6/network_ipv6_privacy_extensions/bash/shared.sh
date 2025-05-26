# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_almalinux

# enable randomness in ipv6 address generation
for interface in /etc/sysconfig/network-scripts/ifcfg-*
do
    echo "IPV6_PRIVACY=rfc3041" >> $interface
done
