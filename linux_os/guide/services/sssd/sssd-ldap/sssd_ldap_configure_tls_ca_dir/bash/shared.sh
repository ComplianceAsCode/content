# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_sssd_ldap_tls_ca_dir

SSSD_CONF="/etc/sssd/sssd.conf"
LDAP_REGEX='[[:space:]]*\[domain\/[^]]*]([^(\n)]*(\n)+)+?[[:space:]]*ldap_tls_cacertdir'
DOMAIN_REGEX="[[:space:]]*\[domain\/[^]]*]"

# Try find [domain/..] and ldap_tls_cacertdir in sssd.conf, if it exists, set to CA directory
# if it isn't here, add it, if [domain/..] doesn't exist, add it here for default domain
if grep -qzosP $LDAP_REGEX $SSSD_CONF; then
        sed -i "s~ldap_tls_cacertdir[^(\n)]*~ldap_tls_cacertdir = $var_sssd_ldap_tls_ca_dir~" $SSSD_CONF
elif grep -qs $DOMAIN_REGEX $SSSD_CONF; then
        sed -i "/$DOMAIN_REGEX/a ldap_tls_cacertdir = $var_sssd_ldap_tls_ca_dir" $SSSD_CONF
else
        mkdir -p /etc/sssd
        touch $SSSD_CONF
        echo -e "[domain/default]\nldap_tls_cacertdir = $var_sssd_ldap_tls_ca_dir" >> $SSSD_CONF
fi
