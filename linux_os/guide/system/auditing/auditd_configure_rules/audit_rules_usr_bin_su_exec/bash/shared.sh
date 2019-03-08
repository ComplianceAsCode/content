# platform = multi_platform_sle


for bits in 32 64 ; do
    if ! grep -qP '^\s*-a always,exit -F -arch=b'"$bits"' path=/usr/bin/su -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged-priv_change\s*$' /etc/audit/audit.rules ; then
        printf '\n-a always,exit -F -arch=b%s path=/usr/bin/su -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged-priv_change\n' "$bits" >> /etc/audit/audit.rules
    fi

done
