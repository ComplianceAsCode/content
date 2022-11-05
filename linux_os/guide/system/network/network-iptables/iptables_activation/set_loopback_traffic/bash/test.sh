#!/bin/bash
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
echo "$passing"
