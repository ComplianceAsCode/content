# platform = multi_platform_all

# shellcheck disable=SC2174
mkdir -p --mode 000 /tmp/tmp-inst
chmod 000 /tmp/tmp-inst
chcon --reference=/tmp /tmp/tmp-inst

if ! grep -Eq '^\s*/tmp\s+/tmp/tmp-inst/\s+level\s+root,adm$' /etc/security/namespace.conf ; then
    if grep -Eq '^\s*/tmp\s+' /etc/security/namespace.conf ; then
        sed -i '/^\s*\/tmp/d' /etc/security/namespace.conf
    fi
    echo "/tmp     /tmp/tmp-inst/        level      root,adm" >> /etc/security/namespace.conf
fi
