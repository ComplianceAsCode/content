# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_almalinux

APPLY_STRING="IPV6_PRIVACY=rfc3041"

# enable randomness in ipv6 address generation
for interface in /etc/sysconfig/network-scripts/ifcfg-*
do
    if ! grep -q "^IPV6_PRIVACY=" "$interface"; then
        echo "$APPLY_STRING" >> "$interface"
    else
        sed -i "s/^IPV6_PRIVACY=.*/$APPLY_STRING/" "$interface"
    fi
done
