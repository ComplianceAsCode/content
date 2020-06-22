# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
replace_or_append "$WEBMIN_CONFIG_FILE" '^passwd_re' '^.*(?=.*[a-z])(?=.*[A-Z])(?=.*[\d])(?=.*[\W]).*$' '@CCENUM@' '%s=%s'
