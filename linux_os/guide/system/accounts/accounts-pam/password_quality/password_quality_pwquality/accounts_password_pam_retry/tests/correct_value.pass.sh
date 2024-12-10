#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ubuntu
# variables = var_password_pam_retry=3

source common.sh

{{% if 'ubuntu' in product %}}
cat << EOF > /usr/share/pam-configs/pwquality
Name: Pwquality password strength checking
Default: yes
Priority: 1024
Conflicts: cracklib
Password-Type: Primary
Password:
    requisite                   pam_pwquality.so retry=3
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update
{{% else %}}
for file in ${configuration_files[@]}; do
{{{ bash_ensure_pam_module_option('/etc/pam.d/$file',
                                   'password',
								   'required',
								   'pam_pwquality.so',
								   'retry',
								   '3',
								   '^\s*account') }}}
done
{{% endif %}}
