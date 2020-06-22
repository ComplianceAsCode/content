# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
replace_or_append "$WEBMIN_CONFIG_FILE" '^homedir_perms' '0750' '@CCENUM@' '%s=%s'
