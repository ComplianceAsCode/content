# platform = multi_platform_sle,multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
{{{ bash_package_install("libpam-pkcs11") }}}
{{% else %}}
{{{ bash_package_install("pam_pkcs11") }}}
{{% endif %}}

if grep "^\s*cert_policy" /etc/pam_pkcs11/pam_pkcs11.conf | grep -q "ca"; then
    sed -i "/^\s*#/! s/cert_policy.*/cert_policy = ca, ocsp_on, signature;/g" /etc/pam_pkcs11/pam_pkcs11.conf
fi
