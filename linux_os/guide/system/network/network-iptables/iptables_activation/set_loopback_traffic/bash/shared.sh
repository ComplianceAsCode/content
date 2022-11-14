# platform = multi_platform_sle

# Implement the loopback rules:
nft add rule inet filter input iif lo accept
nft create rule inet filter input ip saddr 127.0.0.0/8 counter drop

# Check IPv6 is disabled, if false implement IPv6 loopback rules
[ -n "$passing" ] && passing=""
[ -z "$(grep "^\s*linux" /boot/grub2/grub.cfg | grep -v ipv6.disabled=1)" ] && passing="true"

grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" \
/etc/sysctl.conf /etc/sysctl.d/*.conf && \
grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" \
/etc/sysctl.conf /etc/sysctl.d/*.conf && sysctl net.ipv6.conf.all.disable_ipv6 | \
grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" && \
sysctl net.ipv6.conf.default.disable_ipv6 | \
grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" && passing="true"

# Is IPv6 Disabled? (true/fasle)
if [ "$passing" = false ] ; then
    nft add rule inet filter input ip6 saddr ::1 counter drop
fi
