# platform = multi_platform_sle

if [ "$(sysctl -n net.ipv6.conf.all.disable_ipv6)" -eq 0 ]; then
  # IPv6 is not disabled, so run the script
  ip6tables -A INPUT -i lo -j ACCEPT
  ip6tables -A OUTPUT -o lo -j ACCEPT
  ip6tables -A INPUT -s ::1 -j DROP
fi
