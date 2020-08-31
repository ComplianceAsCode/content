# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

SSSD_CONF="/etc/sssd/sssd.conf"
LDAP_REGEX='[[:space:]]*\[domain\/[^]]*]([^(\n)]*(\n)+)+?[[:space:]]*ldap_id_use_start_tls'
AD_REGEX='[[:space:]]*\[domain\/[^]]*]([^(\n)]*(\n)+)+?[[:space:]]*id_provider[[:space:]]*=[[:space:]]*((?i)ad)[[:space:]]*$'
DOMAIN_REGEX="[[:space:]]*\[domain\/[^]]*]"

# Check if id_provider is not set to ad (Active Directory) which makes start_tls not applicable, note the -v option to invert the grep.
# Try to find [domain/..] and ldap_id_use_start_tls in sssd.conf, if it exists, set to 'True'
# if ldap_id_use_start_tls isn't here, add it
# if [domain/..] doesn't exist, add it here for default domain
if grep -qvzosP $AD_REGEX $SSSD_CONF; then
        if grep -qzosP $LDAP_REGEX $SSSD_CONF; then
                sed -i 's/ldap_id_use_start_tls[^(\n)]*/ldap_id_use_start_tls = True/' $SSSD_CONF
        elif grep -qs $DOMAIN_REGEX $SSSD_CONF; then
                sed -i "/$DOMAIN_REGEX/a ldap_id_use_start_tls = True" $SSSD_CONF
        else
                mkdir -p /etc/sssd
                touch $SSSD_CONF
                echo -e "[domain/default]\nldap_id_use_start_tls = True" >> $SSSD_CONF
        fi
fi
