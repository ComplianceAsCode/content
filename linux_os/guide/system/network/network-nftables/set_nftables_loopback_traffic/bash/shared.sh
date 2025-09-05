# platform = multi_platform_all

{{% if "ubuntu" in product %}}
{{{ bash_instantiate_variables("var_nftables_family") }}}
{{% endif %}}

grubfile="{{{ grub2_boot_path }}}/grub.cfg"

# Implement the loopback rules:
nft add rule inet filter input iif lo accept
nft add rule inet filter input ip saddr 127.0.0.0/8 counter drop

# Check IPv6 is disabled, if false implement IPv6 loopback rules
disabled="false"
[ -f "$grubfile" ] && ! grep "^\s*linux" "$grubfile" | grep -vq "ipv6.disable=1" && disabled="true"

grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" \
/etc/sysctl.conf /etc/sysctl.d/*.conf && \
grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" \
/etc/sysctl.conf /etc/sysctl.d/*.conf && sysctl net.ipv6.conf.all.disable_ipv6 | \
grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" && \
sysctl net.ipv6.conf.default.disable_ipv6 | \
grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b(\s+#.*)?$" && disabled="true"

# Is IPv6 Disabled? (true/false)
if [ "$disabled" = false ] ; then
    nft add rule inet filter input ip6 saddr ::1 counter drop
fi

{{% if "ubuntu" in product %}}
nft list ruleset > "/etc/${var_nftables_family}-filter.rules"
{{% endif %}}
