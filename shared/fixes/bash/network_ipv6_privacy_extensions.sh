# platform = multi_platform_rhel

# enable randomness in ipv6 address generation
for interface in /etc/sysconfig/network-scripts/ifcfg-*
do
    echo "IPV6_PRIVACY=rfc3041" >> $interface
done
