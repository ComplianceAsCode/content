# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_sle,multi_platform_ubuntu
SECURITY_LIMITS_FILE="/etc/security/limits.conf"

if grep -qE '^\s*\*\s+hard\s+core' $SECURITY_LIMITS_FILE; then
        sed -ri 's/(hard\s+core\s+)[[:digit:]]+/\1 0/' $SECURITY_LIMITS_FILE
else
        echo "*     hard   core    0" >> $SECURITY_LIMITS_FILE
fi

if ls /etc/security/limits.d/*.conf > /dev/null; then
        sed -ri '/^\s*\*\s+hard\s+core/d' /etc/security/limits.d/*.conf
fi
