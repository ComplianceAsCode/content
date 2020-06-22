# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

WEBMIN_CONFIG_FILE="/etc/webmin/miniserv.conf"
replace_or_append "$WEBMIN_CONFIG_FILE" '^ssl' '1' '@CCENUM@' '%s=%s'
replace_or_append "$WEBMIN_CONFIG_FILE" '^ssl_redirect' '1' '@CCENUM@' '%s=%s'
