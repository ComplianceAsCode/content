# platform = multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu
{{% if 'ubuntu' in product %}}
cat << EOF > /usr/share/pam-configs/cac_pkcs11
Name: Enable pkcs11
Conflicts: pkcs11
Default: yes
Priority: 512
Auth-Type: Primary
Auth:
    [success=end default=ignore]	pam_pkcs11.so
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable cac_pkcs11
{{% else %}}
{{{ bash_ensure_pam_module_options('/etc/pam.d/common-auth', 'auth','sufficient', 'pam_pkcs11.so', '', '', '') }}}
{{% endif %}}
