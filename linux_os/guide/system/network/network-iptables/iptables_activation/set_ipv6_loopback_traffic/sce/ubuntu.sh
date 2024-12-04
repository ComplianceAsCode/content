#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

# Pass rule if IPv6 is disabled on kernel
if [ ! -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] || [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 1 ]; then
    exit "$XCCDF_RESULT_PASS"
fi

{{% if product in ['ubuntu2404'] %}}
regex_input="\s+[0-9]+\s+[0-9]+\s+ACCEPT\s+[0-9]+\s+--\s+lo\s+\*\s+::\/0\s+::\/0[[:space:]]+[0-9]+\s+[0-9]+\s+DROP\s+[0-9]+\s+--\s+\*\s+\*\s+::1\s+::\/0"
regex_output="\s[0-9]+\s+[0-9]+\s+ACCEPT\s+[0-9]+\s+--\s+\*\s+lo\s+::\/0\s+::\/0"
{{% else %}}
regex_input="\s+[0-9]+\s+[0-9]+\s+ACCEPT\s+all\s+lo\s+\*\s+::\/0\s+::\/0[[:space:]]+[0-9]+\s+[0-9]+\s+DROP\s+all\s+\*\s+\*\s+::1\s+::\/0"
regex_output="\s[0-9]+\s+[0-9]+\s+ACCEPT\s+all\s+\*\s+lo\s+::\/0\s+::\/0"
{{% endif %}}

# Check chain INPUT for loopback related rules
if ! ip6tables -L INPUT -v -n -x | grep -Ezq "$regex_input" ; then
    exit "$XCCDF_RESULT_FAIL"
fi

 # Check chain OUTPUT for loopback related rules
if ! ip6tables -L OUTPUT -v -n -x | grep -Eq "$regex_output"; then
    exit "$XCCDF_RESULT_FAIL"
fi

exit "$XCCDF_RESULT_PASS"
