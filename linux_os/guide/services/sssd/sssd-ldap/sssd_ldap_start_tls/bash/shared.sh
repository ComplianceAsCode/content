# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

AUTHCONFIG="/etc/sysconfig/authconfig"
USELDAPAUTH_REGEX="^USELDAPAUTH="
SSSD_CONF="/etc/sssd/sssd.conf"
LDAP_REGEX='[[:space:]]*\[domain\/[^]]*]([^(\n)]*(\n)+)+?[[:space:]]*ldap_id_use_start_tls'
DOMAIN_REGEX="[[:space:]]*\[domain\/[^]]*]"

# Try find USELDAPAUTH in authconfig. If its here set to 'yes', otherwise append USELDAPAUTH=yes
grep -qs "^USELDAPAUTH=" "$AUTHCONFIG" && sed -i 's/^USELDAPAUTH=.*/USELDAPAUTH=yes/g' $AUTHCONFIG
if ! [ $? -eq 0 ]; then
        echo "USELDAPAUTH=yes" >> $AUTHCONFIG
fi

# Try find [domain/..] and ldap_id_use_start_tls in sssd.conf, if it exists, set to 'True'
# if ldap_id_use_start_tls isn't here, add it
# if [domain/..] doesn't exist, add it here for default domain
if grep -qzosP $LDAP_REGEX $SSSD_CONF; then
        sed -i 's/ldap_id_use_start_tls[^(\n)]*/ldap_id_use_start_tls = True/' $SSSD_CONF
elif grep -qs $DOMAIN_REGEX $SSSD_CONF; then
        sed -i "/$DOMAIN_REGEX/a ldap_id_use_start_tls = True" $SSSD_CONF
else
        mkdir -p /etc/sssd
        touch $SSSD_CONF
        echo -e "[domain/default]\nldap_id_use_start_tls = True" >> $SSSD_CONF
fi
