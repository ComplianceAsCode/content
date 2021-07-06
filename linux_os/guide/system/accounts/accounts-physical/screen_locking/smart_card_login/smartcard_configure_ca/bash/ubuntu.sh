# platform = multi_platform_ubuntu

if [ ! -f /etc/pam_pkcs11/pam_pkcs11.conf ]; then
    cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
fi

if grep use_pkcs11_module /etc/pam_pkcs11/pam_pkcs11.conf | awk '/pkcs11_module opensc {/,/}/' /etc/pam_pkcs11/pam_pkcs11.conf | grep cert_policy | grep ca; then
    sed -i "/^\s*#/! s/cert_policy.*/cert_policy = ca,signature,ocsp_on;/g" /etc/pam_pkcs11/pam_pkcs11.conf
fi
