# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

{{{ bash_instantiate_variables("var_sssd_memcache_timeout") }}}

SSSD_CONF="/etc/sssd/sssd.conf"
MEMCACHE_TIMEOUT_REGEX="[[:space:]]*\[nss]([^\n\[]*\n+)+?[[:space:]]*memcache_timeout"
NSS_REGEX="[[:space:]]*\[nss]"

# Try find [nss] and memcache_timeout in sssd.conf, if it exists, set to
# var_sssd_memcache_timeout, if it isn't here, add it, if [nss] doesn't
# exist, add it there
if grep -qzosP $MEMCACHE_TIMEOUT_REGEX $SSSD_CONF; then
        sed -i "s/memcache_timeout[^(\n)]*/memcache_timeout = $var_sssd_memcache_timeout/" $SSSD_CONF
elif grep -qs $NSS_REGEX $SSSD_CONF; then
        sed -i "/$NSS_REGEX/a memcache_timeout = $var_sssd_memcache_timeout" $SSSD_CONF
else
        mkdir -p /etc/sssd
        touch $SSSD_CONF
        echo -e "[nss]\nmemcache_timeout = $var_sssd_memcache_timeout" >> $SSSD_CONF
fi
