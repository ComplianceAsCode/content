# platform = multi_platform_all

# shellcheck disable=SC2174
mkdir -p --mode 000 /var/tmp/tmp-inst
chmod 000 /var/tmp/tmp-inst
chcon --reference=/var/tmp /var/tmp/tmp-inst

if ! grep -Eq '^\s*/var/tmp\s+/var/tmp/tmp-inst/\s+level\s+root,adm$' /etc/security/namespace.conf ; then
    if grep -Eq '^\s*/var/tmp\s+' /etc/security/namespace.conf ; then
        sed -i '/^\s*\/var\/tmp/d' /etc/security/namespace.conf
    fi
    echo "/var/tmp /var/tmp/tmp-inst/    level      root,adm" >> /etc/security/namespace.conf
fi
