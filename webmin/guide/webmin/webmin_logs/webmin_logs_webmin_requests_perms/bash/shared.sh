# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

WEBMIN_CONFIG_FILE="/etc/webmin/miniserv.conf"
replace_or_append "$WEBMIN_CONFIG_FILE" '^logperms' '640' '@CCENUM@' '%s=%s'
