# platform = multi_platform_ubuntu
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

# sssd configuration files must be created with 600 permissions if they don't exist
# otherwise the sssd module fails to start
OLD_UMASK=$(umask)
umask u=rw,go=

# find key in section and change value
found=false
# find key in section and change value
if grep -qzosP "[[:space:]]*\[domain/.*\]([^\n\[]*\n+)+?[[:space:]]*ca_cert" "/etc/sssd/sssd.conf"; then
    sed -i "s/ca_cert[^(\n)]*/ca_cert = \/etc\/ssl\/certs\/ca-certificates.crt/" "/etc/sssd/sssd.conf"
    found=true

# find section and add key = value to it
elif grep -qs "[[:space:]]*\[domain/.*\]" "/etc/sssd/sssd.conf"; then
    sed -i "/[[:space:]]*certificate_verification/a ca_cert = \/etc\/ssl\/certs\/ca-certificates.crt" "/etc/sssd/sssd.conf"
    found=true
fi

# if section not in file, append section with key = value \
if ! $found ; then
    mkdir -p "/etc/sssd"
    echo -e "\n[domain/example.com]\nca_cert = /etc/ssl/certs/ca-certificates.crt" >> "/etc/sssd/sssd.conf"
fi

if grep -qzosP "[[:space:]]*\[domain/.*\]([^\n\[]*\n+)+?[[:space:]]*certificate_verification" "/etc/sssd/sssd.conf"; then
    sed -i "s/certificate_verification[^(\n)]*/certificate_verification = ca_cert,ocsp/" "/etc/sssd/sssd.conf"

# find section and add key = value to it
else
    sed -i "/[[:space:]]*\[domain\/.*\]/a certificate_verification = ca_cert,ocsp" "/etc/sssd/sssd.conf"
fi

# find key in section and change value
if grep -qzosP "[[:space:]]*\[domain/.*\]([^\n\[]*\n+)+?[[:space:]]*ldap_user_certificate" "/etc/sssd/sssd.conf"; then
    sed -i "s/ldap_user_certificate[^(\n)]*/ldap_user_certificate = usercertificate;binary/" "/etc/sssd/sssd.conf"

# find section and add key = value to it
else
    sed -i "/[[:space:]]*\[domain\/.*\]/a ldap_user_certificate = usercertificate;binary" "/etc/sssd/sssd.conf"
fi

umask $OLD_UMASK
