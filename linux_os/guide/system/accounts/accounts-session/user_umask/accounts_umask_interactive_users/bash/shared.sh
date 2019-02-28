# platform = multi_platform_sle

if grep -q '^UMASK' /etc/login.defs ; then
    sed -i --follow-symlinks -E -e 's/^UMASK[^\n]+/UMASK 077/' /etc/login.defs
else
    echo 'UMASK 077' >> /etc/login.defs
fi
