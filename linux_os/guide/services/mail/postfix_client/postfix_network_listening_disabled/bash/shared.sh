# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("var_postfix_inet_interfaces") }}}

CONFIGFILE="/etc/postfix/main.cf"

if [ -f $CONFIGFILE ]; then
  if grep -q '^[\s]*inet_interfaces.*$' $CONFIGFILE; then
    sed -i "s/^\([[:space:]]*inet_interfaces\).*$/\1 = $var_postfix_inet_interfaces/" $CONFIGFILE
  else
    echo "inet_interfaces = $var_postfix_inet_interfaces" > $CONFIGFILE
  fi
fi
