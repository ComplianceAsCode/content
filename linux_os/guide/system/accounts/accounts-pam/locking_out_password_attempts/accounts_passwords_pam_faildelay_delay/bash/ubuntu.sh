# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_delay") }}}
cat << EOF > /usr/share/pam-configs/cac_faildelay
Name: Enable faildelay
Conflicts: faildelay
Default: yes
Priority: 513
Auth-Type: Primary
Auth:
    required                   pam_faildelay.so delay=$var_password_pam_delay
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable cac_faildelay
