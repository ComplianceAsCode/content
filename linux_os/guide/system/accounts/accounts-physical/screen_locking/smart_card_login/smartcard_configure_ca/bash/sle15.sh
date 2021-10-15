# platform = multi_platform_sle

if rpm -qa pam_pkcs11; then
    if grep "^\s*cert_policy" /etc/pam_pkcs11/pam_pkcs11.conf | grep -q "ca"; then
        sed -i "/^\s*#/! s/cert_policy.*/cert_policy = ca, ocsp_on, signature;/g" /etc/pam_pkcs11/pam_pkcs11.conf
    fi
fi
