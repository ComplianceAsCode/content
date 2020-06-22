# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

WEBMIN_CONFIG_FILE="/etc/webmin/miniserv.conf"
if [ "$(grep -c no_ssl3 /usr/libexec/webmin/miniserv.pl)" = "0" ]; then
	replace_or_append "$WEBMIN_CONFIG_FILE" '^ssl_cipher_list' 'ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:+TLSv1.2:+TLSv1:!MD5:!SSLv2:!SSLv3:!ADH:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM' '@CCENUM@' '%s=%s'
else
	replace_or_append "$WEBMIN_CONFIG_FILE" '^ssl_cipher_list' 'ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:+TLSv1.2:+TLSv1:!MD5:!SSLv2:SSLv3:!ADH:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM' '@CCENUM@' '%s=%s'
	replace_or_append "$WEBMIN_CONFIG_FILE" '^no_ssl2' '1' '@CCENUM@' '%s=%s'
	replace_or_append "$WEBMIN_CONFIG_FILE" '^no_ssl3' '1' '@CCENUM@' '%s=%s'
fi
replace_or_append "$WEBMIN_CONFIG_FILE" '^ssl_honorcipherorder' '1' '@CCENUM@' '%s=%s'
