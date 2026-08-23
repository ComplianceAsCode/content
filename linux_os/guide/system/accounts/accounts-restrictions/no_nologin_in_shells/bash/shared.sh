# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if grep -q -E "^[^#]*/nologin\b.*$" /etc/shells; then
  sed -i --follow-symlinks 's/^[^#]*\/nologin\b.*$/#&/g' /etc/shells
fi

